{lib, ...}: {
  options.flake.modules = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
    default = {};
    description = ''
      Named, composable pieces of nixos/home-manager config, keyed by kind
      (e.g. "nixos", "homeManager") then name. This is what makes the
      Dendritic pattern work: every file under modules/ and hosts/ can
      contribute here, and host definitions compose the pieces they need.
    '';
  };
}
