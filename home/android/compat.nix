# Home Manager 24.05 compatibility polyfill for options introduced in later HM releases.
# Import this *before* any module that uses newer option names.
{
  config,
  lib,
  pkgs,
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

    # herdr: HM 24.05 has no upstream programs/herdr module at all.
    # Minimal backport (immutable settings only) in `config` below.
    programs.herdr = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.herdr;
        defaultText = "pkgs.herdr";
      };
      settings = lib.mkOption {
        # Deep-merging type (like upstream), so keybindings from several
        # modules combine instead of replacing each other.
        type = (pkgs.formats.toml {}).type;
        default = {};
      };
    };
  };

  config = {
    # Forward the new free-form programs.ssh.settings onto HM-24.05's API.
    # HM-24.05 renders: matchBlocks, then a hardcoded `Host *` block built
    # from its top-level options (addKeysToAgent, ...), with extraConfig
    # appended *inside* that block. OpenSSH uses the first obtained value,
    # so "*" settings must go to those top-level options — rendering our own
    # `Host *` in extraConfig loses to HM's defaults (e.g. AddKeysToAgent no).
    programs.ssh = let
      settings = config.programs.ssh.settings;
      star = settings."*" or {};
      renderValue = value:
        if builtins.isBool value
        then
          (
            if value
            then "yes"
            else "no"
          )
        else toString value;
      # ssh_config key -> HM-24.05 top-level option (raw values, typed)
      known = {
        ForwardAgent = "forwardAgent";
        AddKeysToAgent = "addKeysToAgent";
        Compression = "compression";
        ServerAliveInterval = "serverAliveInterval";
        ServerAliveCountMax = "serverAliveCountMax";
        HashKnownHosts = "hashKnownHosts";
        UserKnownHostsFile = "userKnownHostsFile";
        ControlMaster = "controlMaster";
        ControlPath = "controlPath";
        ControlPersist = "controlPersist";
      };
      starRest = lib.filterAttrs (k: _: !(known ? ${k})) star;
    in {
      # Attribute names must be static (computing them from config recurses).
      forwardAgent = lib.mkIf (star ? ForwardAgent) star.ForwardAgent;
      addKeysToAgent = lib.mkIf (star ? AddKeysToAgent) star.AddKeysToAgent;
      compression = lib.mkIf (star ? Compression) star.Compression;
      serverAliveInterval = lib.mkIf (star ? ServerAliveInterval) star.ServerAliveInterval;
      serverAliveCountMax = lib.mkIf (star ? ServerAliveCountMax) star.ServerAliveCountMax;
      hashKnownHosts = lib.mkIf (star ? HashKnownHosts) star.HashKnownHosts;
      userKnownHostsFile = lib.mkIf (star ? UserKnownHostsFile) star.UserKnownHostsFile;
      controlMaster = lib.mkIf (star ? ControlMaster) star.ControlMaster;
      controlPath = lib.mkIf (star ? ControlPath) star.ControlPath;
      controlPersist = lib.mkIf (star ? ControlPersist) star.ControlPersist;
      # Leftover "*" keys: no HM default exists, so extraConfig is safe.
      extraConfig = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (k: v: "${k} ${renderValue v}") starRest
      );
      matchBlocks =
        lib.mapAttrs (_: opts: {
          extraOptions = lib.mapAttrs (_: renderValue) opts;
        })
        (lib.filterAttrs (name: _: name != "*") settings);
    };

    # herdr: package + immutable config.toml, as upstream with the default
    # mutableSettings = false.
    home.packages = lib.mkIf config.programs.herdr.enable [config.programs.herdr.package];
    xdg.configFile."herdr/config.toml" = lib.mkIf (config.programs.herdr.enable && config.programs.herdr.settings != {}) {
      source = (pkgs.formats.toml {}).generate "herdr-config.toml" config.programs.herdr.settings;
      onChange = "${lib.getExe config.programs.herdr.package} server reload-config || true";
    };

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
