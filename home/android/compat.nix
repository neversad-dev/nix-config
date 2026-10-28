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

    # New SSH module API. Render these blocks as extraConfig on HM-24.05;
    # it has matchBlocks instead of the free-form settings option.
    programs.ssh.enableDefaultConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    programs.ssh.settings = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
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
    # Specific hosts before Host *; OpenSSH uses the first obtained value.
    # HM-24.05's own defaults follow extraConfig and cannot override these.
    programs.ssh.extraConfig = lib.mkIf config.programs.ssh.enable (let
      settings = config.programs.ssh.settings;
      hosts =
        lib.filter (name: name != "*") (builtins.attrNames settings)
        ++ lib.optional (settings ? "*") "*";
      renderValue = value:
        if builtins.isBool value
        then
          (
            if value
            then "yes"
            else "no"
          )
        else toString value;
      renderHost = name:
        "Host ${name}\n"
        + lib.concatStringsSep "\n"
        (lib.mapAttrsToList (key: value: "  ${key} ${renderValue value}") settings.${name});
    in
      lib.concatMapStringsSep "\n\n" renderHost hosts);

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

    # historyWidgetCommand is a removed option on HM-24.05 (asserts if set),
    # so programs.fzf.historyWidget.command is swallowed, not forwarded.

    # Forward git settings → extraConfig
    programs.git.extraConfig =
      lib.mkIf (config.programs.git.settings != {})
      config.programs.git.settings;
  };
}
