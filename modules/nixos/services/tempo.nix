{...}: {
  flake.modules.nixos.tempo = {
    config,
    lib,
    ...
  }: let
    cfg = config.infra.monitoring.tempo;
    port = 3200;
  in {
    options.infra.monitoring.tempo.enable = lib.mkEnableOption "Tempo";

    config = lib.mkIf cfg.enable {
      homelab.traefik = {
        enable = true;
        services.tempo.port = port;
      };

      services.tempo = {
        enable = true;
        settings = {
          server.http_listen_port = port;
          distributor.receivers.otlp.protocols = {
            http = {};
            grpc = {};
          };
          ingester.max_block_duration = "5m";
          compactor.compaction.block_retention = "48h";
          storage.trace = {
            backend = "local";
            local.path = "/var/lib/tempo/traces";
            wal.path = "/var/lib/tempo/wal";
          };
        };
      };
    };
  };
}
