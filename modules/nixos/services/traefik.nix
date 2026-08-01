{...}: {
  flake.modules.nixos.traefik = {
    config,
    lib,
    ...
  }: let
    vps = config.homelab;
    cfg = vps.traefik;
    hasTLS = cfg.cloudflareTLS.enable;
    prometheusEnabled = config.infra.monitoring.victoriametrics.enable;

    serviceOptions = _:
      with lib; {
        options = {
          host = mkOption {
            type = types.str;
            default = "127.0.0.1";
          };
          port = mkOption {
            type = types.port;
          };
          ipWhitelist = mkOption {
            type = types.str;
            default = "";
          };
          middlewares = mkOption {
            type = types.listOf types.str;
            default = [];
          };
        };
      };

    metricsOptions = _:
      with lib; {
        options = {
          host = mkOption {
            type = types.str;
            default = "127.0.0.1";
          };
          port = mkOption {
            type = types.port;
            default = 0;
          };
          service = mkOption {
            type = types.str;
            default = "";
          };
        };
      };

    mkService = name: value: {
      loadBalancer = {
        servers = [
          {url = "http://${value.host}:${builtins.toString value.port}";}
        ];
      };
    };
    mkRouter = name: value: let
      ipWhitelist =
        if (value.ipWhitelist != "")
        then value.ipWhitelist
        else cfg.defaultIPWhitelist;
    in {
      rule = "Host(`${name}.${vps.domain}`)";
      service = name;
      entrypoints = [cfg.entrypoint];
      middlewares = value.middlewares ++ lib.lists.optional (ipWhitelist != "") ipWhitelist;
    };
    mkMetricsRouter = name: value:
      lib.nameValuePair "${name}-metrics" {
        rule = "Host(`${name}.${vps.domain}`) && Path(`/metrics`)";
        service =
          if (value.service != "")
          then value.service
          else name;
        entrypoints = [cfg.entrypoint];
        middlewares = ["localhost-only"];
      };
  in {
    options.homelab.traefik = with lib; {
      enable = mkEnableOption "traefik";
      docker.enable = mkEnableOption "docker" // {default = config.virtualisation.docker.enable;};
      services = mkOption {
        type = types.attrsOf (types.submodule serviceOptions);
        default = {};
      };
      metrics = mkOption {
        type = types.attrsOf (types.submodule metricsOptions);
        default = {};
      };
      cloudflareTLS = {
        enable = mkEnableOption "cloudflareTLS";
        apiEmailFile = mkOption {
          type = types.str;
        };
        dnsApiTokenFile = mkOption {
          type = types.str;
        };
      };
      entrypoint = mkOption {
        default =
          if hasTLS
          then "websecure"
          else "web";
        readOnly = true;
      };
      defaultIPWhitelist = mkOption {
        type = types.str;
        default = "";
      };
    };

    config = lib.mkIf cfg.enable (lib.mkMerge [
      {
        networking.firewall.allowedTCPPorts = [80] ++ lib.lists.optional hasTLS 443;
        systemd.services.traefik.environment = lib.mkIf hasTLS {
          CF_DNS_API_TOKEN_FILE = cfg.cloudflareTLS.dnsApiTokenFile;
        };

        services.traefik = {
          enable = true;
          staticConfigOptions = lib.mkMerge [
            {
              log.level = "info";
              providers = lib.mkIf cfg.docker.enable {
                docker = {
                  endpoint = "unix:///var/run/podman/podman.sock";
                };
              };
              entryPoints.web.address = ":80";
              api.dashboard = true;
              global = {
                checknewversion = false;
                sendanonymoususage = false;
              };
            }
            (lib.mkIf hasTLS {
              entryPoints = {
                web = {
                  http.redirections.entryPoint = {
                    to = "websecure";
                    scheme = "https";
                  };
                };
                websecure = {
                  address = ":443";
                  http.tls = {
                    certResolver = "cloudflare";
                    domains = [
                      {
                        main = "${vps.domain}";
                        sans = ["*.${vps.domain}"];
                      }
                    ];
                  };
                };
              };
              certificatesResolvers = {
                cloudflare = {
                  acme = {
                    email = "ryanblignuat902@gmail.com";
                    storage = "${config.services.traefik.dataDir}/acme.json";
                    dnsChallenge = {
                      provider = "cloudflare";
                      resolvers = ["1.1.1.1:53" "1.0.0.1:53"];
                    };
                  };
                };
              };
            })
          ];
          dynamicConfigOptions = {
            http = {
              routers = lib.mkMerge [
                (builtins.mapAttrs mkRouter cfg.services)
                {
                  traefik = {
                    rule = "Host(`traefik.${vps.domain}`)";
                    service = "api@internal";
                    middlewares = lib.lists.optional (cfg.defaultIPWhitelist != "") cfg.defaultIPWhitelist;
                    entrypoints = [cfg.entrypoint];
                  };
                }
              ];
              services = builtins.mapAttrs mkService cfg.services;
              middlewares = {
                localhost-only.IPWhitelist.sourceRange = ["127.0.0.1/32"];
                local-ip-whitelist.IPWhiteList = {
                  sourceRange = [
                    "127.0.0.1/32"
                    "10.0.0.0/8"
                    "172.16.0.0/12"
                    "192.168.0.1/16"
                  ];
                };
              };
            };
          };
        };
      }

      (lib.mkIf prometheusEnabled {
        homelab.traefik.metrics.traefik.service = "prometheus@internal";
        services = {
          traefik = {
            staticConfigOptions.metrics.prometheus.manualRouting = true;
            dynamicConfigOptions.http = {
              routers = lib.mapAttrs' mkMetricsRouter cfg.metrics;
              services = builtins.mapAttrs mkService (lib.filterAttrs (n: v: v.port != 0) cfg.metrics);
            };
          };
          prometheus.scrapeConfigs = [
            {
              job_name = "traefik";
              static_configs = [{targets = ["traefik.${vps.domain}"];}];
            }
          ];
          # grafana.provision.dashboards.settings.providers = [
          #   {
          #     name = "traefik";
          #     options.path = ./dashboards/traefik.json;
          #   }
          # ];
        };
        networking.hosts."127.0.0.1" = ["traefik.${vps.domain}"];
      })
    ]);
  };
}
