{
  config,
  lib,
  pkgs,
  nix-secrets,
  catppuccin-pi,
  isHm24 ? false, # set by hosts using HM 24.05 (nix-on-droid)
  ...
}:
with lib; let
  cfg = config.features.ai;
  jsonFormat = pkgs.formats.json {};
  # `lib.modules ? importApply` became true on HM 24.05 once pkgs.lib
  # comes from unstable, so hosts flag HM 24.05 explicitly.
  hasModule = !isHm24 && lib.modules ? importApply;

  piKeyPath = "${config.xdg.dataHome}/secrets/openrouter-pi";

  piOpenrouterKey = pkgs.writeShellScript "pi-openrouter-key" ''
    f=${escapeShellArg piKeyPath}
    if [ ! -s "$f" ]; then
      printf '%s\n' "pi: OpenRouter key missing or empty at $f -- is agenix activated?" >&2
      exit 1
    fi
    exec ${pkgs.coreutils}/bin/cat "$f"
  '';
in
  if hasModule
  then {
    imports = [
      catppuccin-pi.homeManagerModules.default
    ];

    config = mkIf cfg.enable {
      assertions = [
        {
          assertion = config.features.secrets.enable;
          message = "features.ai requires features.secrets to be enabled (OpenRouter API key needs decryption)";
        }
      ];

      programs.pi.catppuccin.enable = config.features.theme.catppuccin.enable;

      # catppuccin-pi patches settings.json from an activation hook; since
      # settings.json is store-managed here, blank that hook and set the theme
      # through `settings` below instead.
      home.activation.setPiTheme = lib.mkForce (lib.hm.dag.entryAfter [] "");

      age.secrets."openrouter-pi" = {
        file = "${nix-secrets}/shared/openrouter-pi.age";
        path = piKeyPath;
        symlink = false;
        mode = "0400";
      };

      home.activation.agenixReapply = mkIf config.features.secrets.enable (
        lib.hm.dag.entryAfter ["linkGeneration"] ''
          run /bin/launchctl kickstart -k gui/$(id -u)/org.nix-community.home.activate-agenix || true
        ''
      );

      programs.pi-coding-agent = {
        enable = true;
        settings =
          {
            defaultProvider = "openrouter";
            defaultModel = "openrouter/auto";
          }
          // optionalAttrs config.features.theme.catppuccin.enable {
            theme = "catppuccin-mocha";
          };
      };

      home.file."${config.programs.pi-coding-agent.configDir}/auth.json" = {
        source = jsonFormat.generate "pi-auth.json" {
          openrouter = {
            type = "api_key";
            key = "!cat ${piOpenrouterKey}";
          };
        };
        force = true;
      };

      home.activation.worktrunkPiIntegration = mkIf config.features.cli.git.extended.enable (
        lib.hm.dag.entryAfter ["linkGeneration"] ''
          export PATH="${lib.makeBinPath [pkgs.git]}:$PATH"
          run sh -c 'cd "$HOME" && echo "y" | ${lib.getExe config.programs.worktrunk.package} config plugins pi install'
        ''
      );

      home.activation.herdrPiIntegration = mkIf config.features.cli.herdr.enable (
        lib.hm.dag.entryAfter ["linkGeneration"] ''
          run ${lib.getExe config.programs.herdr.package} integration install pi
        ''
      );

      home.activation.atuinPiExtension = mkIf config.features.cli.atuin.enable (
        lib.hm.dag.entryAfter ["linkGeneration"] ''
          run ${lib.getExe config.programs.atuin.package} hook install pi
        ''
      );
    };
  }
  else {
    # nixpkgs-24.05 doesn't have lib.modules.importApply;
    # catppuccin-pi module requires newer HM. Skip entirely.
  }
