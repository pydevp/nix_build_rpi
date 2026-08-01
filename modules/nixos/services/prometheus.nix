_: {
  flake.modules.nixos.victoriametrics = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.infra.monitoring.victoriametrics;
    hl = config.homelab;
    vm = config.services.victoriametrics;
    nodeExporter = config.services.prometheus.exporters.node;

    # YAML 1.2 is a superset of JSON, and promscrape's parser accepts it as-is.
    # So we skip pkgs.formats.yaml (and therefore remarshal) entirely and hand
    # VictoriaMetrics the JSON directly via -promscrape.config.
    promscrapeConfig = pkgs.writeText "promscrape.yml" (builtins.toJSON {
      global.scrape_interval = "10s";
      scrape_configs = [
        {
          job_name = config.networking.hostName;
          static_configs = [
            {
              targets = ["node-exporter.${hl.domain}"];
            }
          ];
        }
      ];
    });
  in {
    options.infra.monitoring.victoriametrics.enable = lib.mkEnableOption "VictoriaMetrics";

    config = lib.mkIf cfg.enable {
      homelab.traefik = {
        enable = true;
        services.victoriametrics = {
          port = lib.toInt (lib.last (lib.splitString ":" vm.listenAddress));
        };
        metrics.node-exporter = {
          port = nodeExporter.port;
        };
      };

      services.prometheus.exporters.node = {
        enable = true;
        enabledCollectors = ["systemd"];
        disabledCollectors = ["btrfs" "mdadm" "selinux" "xfs"];
      };

      services.victoriametrics = {
        enable = true;
        retentionPeriod = "30d";
        listenAddress = ":8428";
        extraOptions = [
          "-promscrape.config=${promscrapeConfig}"
          "-memory.allowedPercent=50"
          "-dedup.minScrapeInterval=10s"
        ];
      };
    };
  };
}
