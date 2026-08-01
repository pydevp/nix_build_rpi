{...}: {
  flake.modules.nixos.common-nixpkgs = {...}: {
    nixpkgs.config.allowUnfree = true;
  };
}
