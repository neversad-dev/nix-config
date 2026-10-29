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
in {
  # Installs the catppuccin-pi theme files but also brings in an activation hook
  # that mutates ~/.pi/agent/settings.json (bad). We disable that hook below.
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

    # Required by the imported catppuccin-pi module. Enables theme support.
    # Follows the global theme flag (vars/features.nix).
    programs.pi.catppuccin.enable = config.features.theme.catppuccin.enable;

    # The module above tries to mutate settings.json at activation time.
    # Override its hook to a no-op since we set the theme declaratively in settings.
    home.activation.setPiTheme = lib.mkForce (lib.hm.dag.entryAfter [] "");

    age.secrets."openrouter-pi" = {
      file = "${nix-secrets}/shared/openrouter-pi.age";
      path = "${config.xdg.dataHome}/secrets/openrouter-pi";
    };

    # The previous activation hook left a regular file here; let HM overwrite it
    # once so the declarative symlink can take over.
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

    # Worktrunk hook: only when git is enabled (worktrunk needs git in PATH).
    home.activation.worktrunkPiIntegration = mkIf config.features.cli.git.enable (
      lib.hm.dag.entryAfter ["linkGeneration"] ''
        export PATH="${lib.makeBinPath [pkgs.git]}:$PATH"
        run sh -c 'cd "$HOME" && echo "y" | ${lib.getExe config.programs.worktrunk.package} config plugins pi install'
      ''
    );

    # Herdr hook: only when herdr is enabled.
    home.activation.herdrPiIntegration = mkIf config.features.cli.herdr.enable (
      lib.hm.dag.entryAfter ["linkGeneration"] ''
        run ${lib.getExe config.programs.herdr.package} integration install pi
      ''
    );

    # Atuin hook: only when atuin is enabled.
    home.activation.atuinPiExtension = mkIf config.features.cli.atuin.enable (
      lib.hm.dag.entryAfter ["linkGeneration"] ''
        run ${lib.getExe config.programs.atuin.package} hook install pi
      ''
    );
  };
}
