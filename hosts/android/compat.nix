# Home Manager 24.05 compatibility polyfill for options introduced in later HM releases.
# Import this *before* any module that uses newer option names.
{
  config,
  lib,
  ...
}: {
  options = {
    # HM 24.11 renamed programs.zsh.initExtra → initContent (same for bash).
    # Declare the newer name so existing mbair modules evaluate cleanly;
    # forward the value to the old name at activation time.
    programs.zsh.initContent = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Polyfill: forwarded to initExtra on HM-24.05.";
    };

    programs.bash.initContent = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Polyfill: forwarded to initExtra on HM-24.05.";
    };

    # fzf: HM 24.11 refactored flat widget options into nested attrsets.
    # HM-24.05 doesn't know about the nested forms, so we declare them here
    # and swallow them silently.
    programs.fzf.fileWidget = lib.mkOption {
      type = lib.types.submodule {
        options.command = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      };
      default = {};
    };

    programs.fzf.historyWidget = lib.mkOption {
      type = lib.types.submodule {
        options.command = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      };
      default = {};
    };

    # worktrunk is a custom HM module (not in nixpkgs-24.05).
    programs.worktrunk = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          enableZshIntegration = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          settings = lib.mkOption {
            type = lib.types.anything;
            default = {};
          };
        };
      };
      default = {};
    };

    # Git: HM 24.11 replaced programs.git.extraConfig with programs.git.settings.
    programs.git.settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Polyfill: forwarded to extraConfig on HM-24.05.";
    };

    # Atuin: daemon option and forceOverwriteSettings were added after HM-24.05.
    programs.atuin.daemon = lib.mkOption {
      type = lib.types.submodule {
        options.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };
      default = {};
    };

    programs.atuin.forceOverwriteSettings = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    # Tealdeer: enableAutoUpdates was added after HM-24.05.
    programs.tealdeer.enableAutoUpdates = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = {
    # Forward initContent → initExtra
    programs.zsh.initExtra =
      lib.mkIf (config.programs.zsh.initContent != "")
      config.programs.zsh.initContent;

    programs.bash.initExtra =
      lib.mkIf (config.programs.bash.initContent != "")
      config.programs.bash.initContent;

    # Forward nested fzf widget options → flat HM-24.05 names
    programs.fzf.fileWidgetCommand =
      lib.mkIf (config.programs.fzf.fileWidget.command != null)
      config.programs.fzf.fileWidget.command;

    programs.fzf.historyWidgetCommand =
      lib.mkIf (config.programs.fzf.historyWidget.command != null)
      config.programs.fzf.historyWidget.command;

    # Forward git settings → extraConfig
    programs.git.extraConfig =
      lib.mkIf (config.programs.git.settings != {})
      config.programs.git.settings;
  };
}
