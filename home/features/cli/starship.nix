# Cross-shell prompt (Starship) (opt-in)
{
  config,
  lib,
  ...
}: with lib; let
  cfg = config.features.cli.starship;
in {
  options.features.cli.starship.enable = mkEnableOption "Starship cross-shell prompt";

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;

      settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      format = "[](fg:surface0)$os$username$hostname[](bg:peach fg:surface0)$directory[](fg:peach bg:green)$git_branch$git_status[](fg:green bg:teal)$c$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:teal bg:blue)$docker_context[](fg:blue bg:purple)$time[ ](fg:purple)$line_break$character";
      add_newline = true;

      os = {
        disabled = false;
        style = "bg:surface0 fg:text";
      };

      # Define OS symbols
      os.symbols = {
        Alpaquita = " ";
        Alpine = " ";
        AlmaLinux = " ";
        Amazon = " ";
        Android = " ";
        Arch = " ";
        Artix = " ";
        CentOS = " ";
        Debian = " ";
        DragonFly = " ";
        Emscripten = " ";
        EndeavourOS = " ";
        Fedora = " ";
        FreeBSD = " ";
        Garuda = "󰛓 ";
        Gentoo = " ";
        HardenedBSD = "󰞌 ";
        Illumos = "󰈸 ";
        Kali = " ";
        Linux = " ";
        Mabox = " ";
        Macos = " ";
        Manjaro = " ";
        Mariner = " ";
        MidnightBSD = " ";
        Mint = " ";
        NetBSD = " ";
        NixOS = " ";
        OpenBSD = "󰈺 ";
        openSUSE = " ";
        OracleLinux = "󰌷 ";
        Pop = " ";
        Raspbian = " ";
        Redhat = " ";
        RedHatEnterprise = " ";
        RockyLinux = " ";
        Redox = "󰀘 ";
        Solus = "󰠳 ";
        SUSE = " ";
        Ubuntu = " ";
        Unknown = " ";
        Void = " ";
        Windows = "󰍲 ";
      };

      username = {
        show_always = true;
        style_user = "bg:surface0 fg:text";
        style_root = "bg:surface0 fg:text";
        format = "[ $user ]($style)";
      };

      directory = {
        style = "fg:mantle bg:peach";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = "󰝚 ";
          "Pictures" = " ";
          "Developer" = "󰲋 ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:teal";
        format = "[[ $symbol $branch ](fg:base bg:green)]($style)";
      };

      git_status = {
        style = "bg:teal";
        format = "[[($all_status$ahead_behind )](fg:base bg:green)]($style)";
      };

      nodejs = {
        symbol = "";
        style = "bg:teal";
        format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
      };

      c = {
        symbol = " ";
        style = "bg:teal";
        format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:teal";
        format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:teal";
        format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
      };

      php = {
        symbol = "";
        style = "bg:teal";
        format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
      };

      java = {
        symbol = " ";
        style = "bg:teal";
        format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
      };

      kotlin = {
        symbol = "";
        style = "bg:teal";
        format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
      };

      haskell = {
        symbol = "";
        style = "bg:teal";
        format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
      };

      python = {
        symbol = "";
        style = "bg:teal";
        format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
      };

      docker_context = {
        symbol = "";
        style = "bg:mantle";
        format = "[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:peach";
        format = "[[  $time ](fg:mantle bg:purple)]($style)";
      };

      line_break = {
        disabled = false;
      };

      character = {
        disabled = false;
        success_symbol = "[](bold fg:green)";
        error_symbol = "[](bold fg:red)";
        vimcmd_symbol = "[](bold fg:green)";
        vimcmd_replace_one_symbol = "[](bold fg:purple)";
        vimcmd_replace_symbol = "[](bold fg:purple)";
        vimcmd_visual_symbol = "[](bold fg:lavender)";
      };
    };
    };
  };
}
