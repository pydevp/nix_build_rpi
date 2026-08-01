{...}: {
  flake.modules.nixos.common-nvf = {...}: {
    programs.nvf = {
      enable = true;
      settings.vim = {
        treesitter.enable = false;
        binds.whichKey.enable = true;
        telescope.enable = true;
        statusline.lualine.enable = true;
      };
    };
  };
}
