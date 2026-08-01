{...}: {
  flake.modules.nixos.host-reze = {lib, ...}: {
    imports = [
      ./_private.nix
      ./_pi5-configtxt.nix
      ./_secrets.nix
    ];

    networking.hostName = "reze-pi";
    time.timeZone = "Africa/Johannesburg";

    homelab = {
      domain = "reze-pi.local";
      storage = "/chonk";
      traefik = {
        enable = lib.mkForce false;
        cloudflareTLS.enable = false;
      };
    };
    infra.monitoring = {
      loki.enable = true;
      victoriametrics.enable = true;
      grafana.enable = false;
      tempo.enable = false;
      alloy.enable = false;
    };
  };
}
