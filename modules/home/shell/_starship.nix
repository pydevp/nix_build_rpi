# starship is a minimal, fast, and extremely customizable prompt for any shell!
{
  config,
  lib,
  ...
}: let
  # accent = "#${config.lib.stylix.colors.base0D}";
  # background-alt = "#${config.lib.stylix.colors.base01}";
in {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = lib.concatStrings [
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$cmd_duration"
        "$nix_shell"
        "$character"
      ];
      # directory = {
      #   style = accent;
      # };

      character = {
        success_symbol = "[❯](white)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](cyan)";
      };

      # git_branch = {
      #   symbol = "[](${background-alt}) ";
      #   style = "fg:${accent} bg:${background-alt}";
      #   format = "on [$symbol$branch]($style)[](${background-alt}) ";
      # };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218)($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "";
        renamed = "";
        deleted = "";
        stashed = "≡";
      };

      git_state = {
        format = "([$state( $progress_current/$progress_total)]($style)) ";
        style = "bright-black";
      };
      memory_usage = {
        symbol = "memory ";
      };
      nix_shell = {
        symbol = "❄️ ";
        format = "[$symbol]($style)";
      };
      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };
      os.symbols = {
        Alpaquita = "alq ";
        Alpine = "alp ";
        Amazon = "amz ";
        Android = "andr ";
        Arch = "rch ";
        Artix = "atx ";
        CentOS = "cent ";
        Debian = "deb ";
        DragonFly = "dfbsd ";
        Emscripten = "emsc ";
        EndeavourOS = "ndev ";
        Fedora = "fed ";
        FreeBSD = "fbsd ";
        Garuda = "garu ";
        Gentoo = "gent ";
        HardenedBSD = "hbsd ";
        Illumos = "lum ";
        Linux = "lnx ";
        Mabox = "mbox ";
        Macos = "mac ";
        Manjaro = "mjo ";
        Mariner = "mrn ";
        MidnightBSD = "mid ";
        Mint = "mint ";
        NetBSD = "nbsd ";
        NixOS = "nix ";
        OpenBSD = "obsd ";
        OpenCloudOS = "ocos ";
        openEuler = "oeul ";
        openSUSE = "osuse ";
        OracleLinux = "orac ";
        Pop = "pop ";
        Raspbian = "rasp ";
        Redhat = "rhl ";
        RedHatEnterprise = "rhel ";
        Redox = "redox ";
        Solus = "sol ";
        SUSE = "suse ";
        Ubuntu = "ubnt ";
        Unknown = "unk ";
        Windows = "win ";
      };
      package = {
        symbol = "pkg ";
      };
      purescript = {
        symbol = "purs ";
      };
      python = {
        format = "[$virtualenv]($style) ";
        style = "bright-black";
        symbol = "py ";
      };
      rust = {
        symbol = "rs ";
      };
      status = {
        symbol = "[x](bold red) ";
      };
      sudo = {
        symbol = "sudo ";
      };
      terraform = {
        symbol = "terraform ";
      };
    };
  };
}
