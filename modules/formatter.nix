{...}: {
  systems = ["aarch64-linux"];

  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;
  };
}
