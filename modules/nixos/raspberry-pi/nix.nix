{...}: {
  flake.modules.nixos.raspberry-pi-nix = {...}: {
    # allow nix-copy to a live system; cache substituter unique to
    # nixos-raspberrypi (general substituters/trusted-users live in
    # common-nix.nix, always co-imported with this module).
    nix.settings = {
      substituters = ["https://nixos-raspberrypi.cachix.org"];
      trusted-substituters = ["https://nixos-raspberrypi.cachix.org"];
      trusted-public-keys = [
        "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      ];
    };
  };
}
