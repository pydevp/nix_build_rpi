{...}: {
  flake.modules.nixos.common-shell = {pkgs, ...}: {
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;
  };
}
