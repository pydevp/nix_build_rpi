{...}: {
  flake.modules.homeManager.ryan = {...}: {
    home.username = "ryan";
    home.homeDirectory = "/home/ryan";
    home.stateVersion = "26.05";
  };
}
