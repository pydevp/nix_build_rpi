{...}: {
  flake.modules.nixos.homelab-options = {lib, ...}: {
    options.homelab = {
      domain = lib.mkOption {
        type = lib.types.str;
      };
      storage = lib.mkOption {
        type = lib.types.str;
        default = "/data";
      };
    };
  };
}
