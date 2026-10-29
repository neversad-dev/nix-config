{
  config,
  lib,
  pkgs,
  nix-secrets,
  catppuccin-pi,
  ...
}:
with lib; let
  cfg = config.features.ai;
  jsonFormat = pkgs.formats.json {};
  hasModule = lib.modules ? importApply;
in
  if hasModule then {
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

      home.activation.setPiTheme = lib.mkForce (lib.hm.dag.entryAfter [] "");

      age.secrets."openrouter-pi" = {
        file = "${nix-secrets}/shared/openrouter-pi.age";
        path = "${config.xdg.dataHome}/secrets/openrouter-pi";
      };

      home.file."${config.programs.pi-coding-agent.configDir}/settings.json".force = true;

      programs.pi-coding-agent = {
        enable = true;
        settings = {
          defaultProvider = "openrouter";
          theme =
            if config.features.theme.catppuccin.enable
            then "catppuccin-mocha"
            else null;
        };
      };

      home.file."${config.programs.pi-coding-agent.configDir}/auth.json" = {
        source = jsonFormat.generate "pi-auth.json" {
          openrouter = {
            type = "api_key";
            key = "!cat ${config.age.secrets."openrouter-pi".path}";
          };
        };
        force = true;
      };

      home.activation.worktrunkPiIntegration = mkIf config.features.cli.git.enable (
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
  } else {
    # nixpkgs-24.05 doesn't have lib.modules.importApply;
    # catppuccin-pi module requires newer HM. Skip entirely.
  }
