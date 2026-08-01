{...}: {
  flake.modules.nixos.raspberry-pi-boot = {config, ...}: {
    # We are stateless, so just default to latest.
    system.stateVersion = config.system.nixos.release;

    system.nixos.tags = let
      cfg = config.boot.loader.raspberry-pi;
    in [
      "raspberry-pi-${cfg.variant}"
      cfg.bootloader
      config.boot.kernelPackages.kernel.version
    ];

    fileSystems = {
      "/boot/firmware" = {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
        options = [
          "noatime"
          "noauto"
          "x-systemd.automount"
          "x-systemd.idle-timeout=1min"
        ];
      };
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
        options = ["noatime"];
      };
    };

    boot.loader.raspberry-pi.bootloader = "kernel";
    boot.tmp.useTmpfs = true;

    systemd.services."modprobe@efi_pstore".enable = false;
    systemd.services."modprobe@fuse".enable = false;
  };
}
