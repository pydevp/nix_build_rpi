{...}: {
  flake.modules.nixos.alloy = {
    config,
    lib,
    ...
  }: let
    cfg = config.infra.monitoring.alloy;
    inherit (lib) mkEnableOption mkOption types mapAttrs' nameValuePair;
    inherit (config.services) loki;
    lokiPort = loki.configuration.server.http_listen_port or 3100;
  in {
    options.infra.monitoring.alloy = {
      enable = (mkEnableOption "Grafana Alloy") // {default = false;};

      exporters = mkOption {
        description = ''
          Set of additional exporters to scrape.

          The attribute name will be used as `job_name`
          internally, which ends up exported as `job` label
          on all metrics of that exporter.
        '';
        type = types.attrsOf (types.submodule ({
          config,
          name,
          ...
        }: {
          options.port = mkOption {
            description = "Exporter port";
            type = types.int;
          };
        }));
        default = {};
      };
    };

    config = lib.mkIf cfg.enable {
      homelab = {
        traefik.enable = true;
      };
      services.alloy.enable = false;

      environment.etc =
        {
          "alloy/config.alloy".text = ''
            // SECTION: TARGETS

            loki.write "default" {
              endpoint {
                url = "http://localhost:${toString lokiPort}/loki/api/v1/push"
              }
              external_labels = {}
            }

            prometheus.remote_write "default" {
              endpoint {
                url = "http://localhost:9090/api/v1/write"
              }
            }

            // !SECTION
            // SECTION: SYSTEM LOGS & JOURNAL
            loki.source.journal "journal" {
              max_age       = "24h0m0s"
              relabel_rules = discovery.relabel.journal.rules
              forward_to    = [loki.write.default.receiver]
              labels        = {component = string.format("%s-journal", constants.hostname)}
              // NOTE: This is important to fix https://github.com/grafana/alloy/issues/924
              path          = "/var/log/journal"
            }

            local.file_match "system" {
              path_targets = [{
                __address__ = "localhost",
                __path__    = "/var/log/{syslog,messages,*.log}",
                instance    = constants.hostname,
                job         = string.format("%s-logs", constants.hostname),
              }]
            }

            discovery.relabel "journal" {
              targets = []
              rule {
                source_labels = ["__journal__systemd_unit"]
                target_label  = "unit"
              }
              rule {
                source_labels = ["__journal__boot_id"]
                target_label  = "boot_id"
              }
              rule {
                source_labels = ["__journal__transport"]
                target_label  = "transport"
              }
              rule {
                source_labels = ["__journal_priority_keyword"]
                target_label  = "level"
              }
            }

            loki.source.file "system" {
              targets    = local.file_match.system.targets
              forward_to = [loki.write.default.receiver]
            }
          '';
        }
        // (mapAttrs'
          (name: v:
            nameValuePair "alloy/scrape_${name}.alloy" {
              text = ''
                prometheus.scrape "${name}" {
                  targets = [
                    {"__address__" = "localhost:${toString v.port}"},
                  ]
                  forward_to = [prometheus.remote_write.mimir.receiver]
                }
              '';
            })
          cfg.exporters);
    };
  };
}
