{
  config,
  lib,
  pkgs,
  ...
}: {
  users.users.ryan = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    hashedPasswordFile = config.sops.secrets."ryan-password-hash".path;
    };
}
