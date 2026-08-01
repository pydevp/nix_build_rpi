{...}: {
  flake.modules.nixos.raspberry-pi-wireless = {...}: {
    # Use iwd instead of wpa_supplicant. It has a user friendly CLI
    networking.wireless.enable = false;
    networking.wireless.iwd = {
      enable = true;
      settings = {
        General = {
          Country = "DE";
          ManagementFrameProtection = 0;
        };
        Network = {
          EnableIPv6 = true;
          RoutePriorityOffset = 300;
        };
        Settings.AutoConnect = true;
      };
    };

    hardware.wirelessRegulatoryDatabase = true;
  };
}
