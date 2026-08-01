{...}: {
  flake.modules.nixos.common-timesyncd = {...}: {
    services.timesyncd.enable = true;
    services.timesyncd.servers = [
      "0.nixos.pool.ntp.org"
      "1.nixos.pool.ntp.org"
      "time.cloudflare.com"
      "time.google.com"
    ];
    time.hardwareClockInLocalTime = false;
  };
}
