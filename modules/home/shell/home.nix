{...}: {
  flake.modules.homeManager.shell = {...}: {
    imports = [
    # ./_zsh.nix 
    ./_zoxide.nix 
    ./_eza.nix 
    # ./_fzf.nix 
    # ./_starship.nix
    ];
  };
}
