{...}: {
  flake.modules.nixos.common-overlays = {...}: {
    nixpkgs.overlays = [
      (final: prev: {
        pythonPackagesExtensions =
          prev.pythonPackagesExtensions
          ++ [
            (pyFinal: pyPrev: {
              # remarshal itself is cheap to check, but its required dependency
              # chain (rich-argparse -> rich -> markdown-it-py) forces
              # markdown-it-py's tests on, which pull in pytest-regressions,
              # which pulls in matplotlib/pandas/numpy/ffmpeg. Disable checks
              # on all three so `pkgs.formats.toml`/`yaml` (used by
              # home-manager, e.g. programs.starship.settings) stays cheap.
              remarshal = pyPrev.remarshal.overrideAttrs (old: {
                doCheck = false;
                doInstallCheck = false;
              });
              markdown-it-py = pyPrev.markdown-it-py.overrideAttrs (old: {
                doCheck = false;
                doInstallCheck = false;
              });
              pytest-regressions = pyPrev.pytest-regressions.overrideAttrs (old: {
                doCheck = false;
                doInstallCheck = false;
              });
            })
          ];
      })
    ];
  };
}
