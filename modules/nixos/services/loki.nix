{...}: {
  flake.modules.nixos.loki = {
    config,
    lib,
    ...
  }: let
    cfg = config.infra.monitoring.loki;
    hl = config.homelab;
    port = 3100;
  in {
    options.infra.monitoring.loki.enable = lib.mkEnableOption "Loki";

    config = lib.mkIf cfg.enable {
      homelab.traefik = {
        enable = true;
        services.loki.port = port;
      };

      services.loki = {
        enable = true;
        dataDir = "${hl.storage}/loki";
        configuration = {
          auth_enabled = false;
          server.http_listen_port = port;
          common = {
            path_prefix = "${hl.storage}/loki";
            replication_factor = 1;
            ring.kvstore.store = "inmemory";
            storage.filesystem = {
              chunks_directory = "${hl.storage}/loki/chunks";
              rules_directory = "${hl.storage}/loki/rules";
            };
          };
          schema_config.configs = [
            {
              from = "2024-01-01";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };
      };
    };
  };
}
