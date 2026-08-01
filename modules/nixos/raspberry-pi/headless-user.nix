{...}: {
  flake.modules.nixos.raspberry-pi-headless-user = {...}: {
    # Default "nixos" user + passwordless root, carried over from the
    # nixos-raspberrypi example flake this repo started from. Headless
    # bring-up convenience; login is only possible after `passwd` or adding
    # an ssh key.
    users.users.nixos = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video"];
      initialHashedPassword = "";
    };
    users.users.root.initialHashedPassword = "";

    security.polkit.enable = true;
    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };

    services.getty.autologinUser = "nixos";

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
  };
}
