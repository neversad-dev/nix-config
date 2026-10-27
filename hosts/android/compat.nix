# Home Manager 24.05 compatibility polyfill for options introduced in later HM releases.
# Import this *before* any module that uses newer option names.
#
# Keep this file focused on forward declarations and forwarding only.
# Anything that cannot be safely polyfilled should get its own guard in the caller.
{ config, lib, ... }:

{
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

    # fzf: HM 24.11 refactored flat widget options into nested attrsets:
    #   fileWidgetCommand  → fileWidget.command
    #   historyWidgetCommand → historyWidget.command
    #   tmuxShellIntegration → tmux.enableShellIntegration
    #
    # HM-24.05 doesn't know about the nested forms, so we declare them here
    # and swallow them silently.  The defaultCommand set by fzf.nix still
    # works for Ctrl-T file search with sensible defaults.
    programs.fzf.fileWidget = lib.mkOption {
      type = lib.types.submodule {
        options.command = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      };
      default = { };
    };

    programs.fzf.historyWidget = lib.mkOption {
      type = lib.types.submodule {
        options.command = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      };
      default = { };
    };

    programs.fzf.tmux = lib.mkOption {
      type = lib.types.submodule {
        options.enableShellIntegration = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };
      default = { };
    };

    # worktrunk is a custom HM module (not in nixpkgs-24.05).
    # Declare a stub so git/worktrunk.nix can set options without crashing eval.
    # The stub is intentionally a no-op; the package is not built on Android.
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
            default = { };
          };
        };
      };
      default = { };
    };
  };

  config = {
    # Forward initContent → initExtra
    programs.zsh.initExtra = lib.mkIf (config.programs.zsh.initContent != "")
      config.programs.zsh.initContent;

    programs.bash.initExtra = lib.mkIf (config.programs.bash.initContent != "")
      config.programs.bash.initContent;
  };
}
