{...}: {
  flake.modules.nixos.grafana = {
    config,
    lib,
    pkgs,
    ...
  }: let
    hl = config.homelab;
    cfg = config.infra.monitoring.grafana;
    mon = config.infra.monitoring;
    inherit (config.services) grafana prometheus loki tempo;
    secretKeyFile = "${hl.storage}/secrets/grafana-secret-key";
  in {
    options.infra.monitoring.grafana.enable = lib.mkEnableOption "Grafana";

    config = lib.mkIf cfg.enable {
      homelab.traefik = {
        enable = true;
        services.grafana = {port = grafana.settings.server.http_port;};
      };

      # Grafana 12 dropped its hardcoded default secret_key; generate a
      # persistent random one on first boot rather than leak it into the
      # world-readable Nix store. See the "file provider" syntax below.
      systemd.services.grafana-secret-key = {
        description = "Generate Grafana's secret_key file if it doesn't exist yet";
        before = ["grafana.service"];
        requiredBy = ["grafana.service"];
        serviceConfig.Type = "oneshot";
        script = ''
          install -d -m 0700 "$(dirname "${secretKeyFile}")"
          if [ ! -s "${secretKeyFile}" ]; then
            umask 077
            ${pkgs.openssl}/bin/openssl rand -hex 32 > "${secretKeyFile}"
          fi
          chown grafana:grafana "${secretKeyFile}"
          chmod 600 "${secretKeyFile}"
        '';
      };

      services.grafana = {
        enable = true;
        settings = {
          server = {
            domain = "grafana.${hl.domain}";
            http_port = 3001;
          };
          analytics = {
            reporting_enabled = false;
            check_for_updates = false;
            check_for_plugin_updates = false;
          };
          security = {
            disable_gravatar = true;
            secret_key = "$__file{${secretKeyFile}}";
          };
          panels.disable_sanitize_html = true;
        };
        provision.datasources.settings.datasources =
          lib.optional mon.prometheus.enable {
            name = "Prometheus";
            type = "prometheus";
            uid = "prometheus";
            access = "proxy";
            url = "http://localhost:${builtins.toString prometheus.port}";
            isDefault = true;
            version = 1;
            editable = false;
          }
          ++ lib.optional mon.loki.enable {
            name = "Loki";
            type = "loki";
            uid = "loki";
            access = "proxy";
            url = "http://localhost:${builtins.toString loki.configuration.server.http_listen_port}";
            isDefault = false;
            version = 1;
            editable = false;
          }
          ++ lib.optional mon.tempo.enable ({
              name = "Tempo";
              type = "tempo";
              uid = "tempo";
              access = "proxy";
              url = "http://localhost:${builtins.toString tempo.settings.server.http_listen_port}";
              isDefault = false;
              version = 1;
              editable = false;
            }
            // lib.optionalAttrs mon.prometheus.enable {
              jsonData.tracesToMetrics.datasourceUid = "prometheus";
            });
      };
    };
  };
}
