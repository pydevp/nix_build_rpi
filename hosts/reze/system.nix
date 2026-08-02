{
  inputs,
  config,
  ...
}: {
  # flake.nixosConfigurations.rpi5 = inputs.nixos-raspberrypi.lib.nixosSystemFull {
  flake.nixosConfigurations.rpi5 = inputs.nixos-raspberrypi.lib.nixosSystem {
    specialArgs = inputs;
    modules = with inputs.nixos-raspberrypi.nixosModules; [
      raspberry-pi-5.base
      raspberry-pi-5.page-size-16k
      raspberry-pi-5.display-vc4

      # inputs.nvf.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops

      config.flake.modules.nixos.common-networking
      config.flake.modules.nixos.common-nix
      config.flake.modules.nixos.common-mdns
      config.flake.modules.nixos.common-timesyncd
      config.flake.modules.nixos.common-nixpkgs
      config.flake.modules.nixos.common-overlays
      # config.flake.modules.nixos.common-nvf
      config.flake.modules.nixos.common-packages
      config.flake.modules.nixos.common-shell
      # config.flake.modules.nixos.common-sops
      config.flake.modules.nixos.homelab-options
      config.flake.modules.nixos.raspberry-pi-headless-user
      config.flake.modules.nixos.raspberry-pi-nix
      config.flake.modules.nixos.raspberry-pi-wireless
      config.flake.modules.nixos.raspberry-pi-boot
      config.flake.modules.nixos.traefik
      config.flake.modules.nixos.alloy
      config.flake.modules.nixos.loki
      config.flake.modules.nixos.victoriametrics
      config.flake.modules.nixos.grafana
      config.flake.modules.nixos.tempo
      config.flake.modules.nixos.host-reze

      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = inputs;
          users.ryan = {
            imports = [
              config.flake.modules.homeManager.shell
              config.flake.modules.homeManager.ryan
            ];
          };
        };
      }
    ];
  };
}
