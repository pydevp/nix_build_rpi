{
  config,
  lib,
  ...
}: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableNushellIntegration = false;
    defaultOptions = [
      "--margin=1"
      "--layout=reverse"
      "--border=rounded"
      "--info='hidden'"
      "--header=''"
      "--prompt='/ '"
      "-i"
      "--no-bold"
    ];
  };
}
