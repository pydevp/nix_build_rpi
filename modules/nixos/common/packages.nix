{...}: {
  flake.modules.nixos.common-packages = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      tree
      htop
      git
      iw
      nh
      # neovim
      alejandra
    ];
  };
}
