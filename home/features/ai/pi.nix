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
    # Required by the imported catppuccin-pi module. Enables theme support.
    programs.pi.catppuccin.enable = true;

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
        theme = "catppuccin-mocha";
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

    # Worktrunk hook: installs the worktrunk pi plugin during activation.
    # The worktrunk CLI internally invokes `git --version` to detect if it is
    # running inside a git repository, so `git` must be available in PATH.
    # Home Manager's activation environment has a minimal PATH without git.
    #
    # The installer interactively prompts for confirmation, so we pipe "y" to
    # auto-accept.  We run from $HOME so the git-detection does not pick up the
    # nix-config repository.
    home.activation.worktrunkPiIntegration = lib.hm.dag.entryAfter ["linkGeneration"] ''
      export PATH="${lib.makeBinPath [pkgs.git]}:$PATH"
      run sh -c 'cd "$HOME" && echo "y" | ${lib.getExe config.programs.worktrunk.package} config plugins pi install'
    '';

    # Herdr hook: installs the herdr pi integration during activation.
    home.activation.herdrPiIntegration = lib.hm.dag.entryAfter ["linkGeneration"] ''
      run ${lib.getExe config.programs.herdr.package} integration install pi
    '';

    # Atuin hook: writes ~/.pi/agent/extensions/atuin.ts from the bundled
    # extension inside the atuin binary, so it always matches the atuin we run.
    # Must NOT be managed by home.file — the installer can't write through a
    # /nix/store symlink.
    home.activation.atuinPiExtension = lib.hm.dag.entryAfter ["linkGeneration"] ''
      run ${lib.getExe config.programs.atuin.package} hook install pi
    '';
  };
}
