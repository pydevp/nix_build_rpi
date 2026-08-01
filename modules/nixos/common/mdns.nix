{...}: {
  flake.modules.nixos.common-mdns = {...}: {
    networking.firewall.allowedUDPPorts = [5353];
    systemd.network.networks = {
      "99-ethernet-default-dhcp".networkConfig.MulticastDNS = "yes";
      "99-wireless-client-dhcp".networkConfig.MulticastDNS = "yes";
    };
    systemd.network.wait-online.enable = false;
  };
}
