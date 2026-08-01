{...}: {
  flake.modules.nixos.common-nix = {lib, ...}: {
    nix.channel.enable = lib.mkDefault false;
    nix.daemonCPUSchedPolicy = lib.mkDefault "batch";
    nix.daemonIOSchedClass = lib.mkDefault "idle";
    nix.daemonIOSchedPriority = lib.mkDefault 7;

    nix.settings.connect-timeout = lib.mkDefault 5;
    nix.settings.fallback = true;
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nix.settings.log-lines = lib.mkDefault 25;
    nix.settings.max-free = lib.mkDefault (3000 * 1024 * 1024);
    nix.settings.min-free = lib.mkDefault (512 * 1024 * 1024);
    nix.optimise.automatic = lib.mkDefault true;
    nix.settings.trusted-users = ["root" "ryan" "nixos"];

    systemd.services.nix-gc.serviceConfig = {
      CPUSchedulingPolicy = "batch";
      IOSchedulingClass = "idle";
      IOSchedulingPriority = 7;
    };

    # Make builds to be more likely killed than important services.
    # 100 is the default for user slices and 500 is systemd-coredumpd@
    # We rather want a build to be killed than our precious user sessions as builds can be easily restarted.
    systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;
  };
}
