{
  config,
  lib,
  pkgs-unstable,
  pkgs,
  nix-secrets,
  ...
}:
with lib; let
  cfg = config.features.ai;
  jsonFormat = pkgs.formats.json {};
in
  mkIf cfg.enable {
    age.secrets."openrouter-pi" = {
      file = "${nix-secrets}/shared/openrouter-pi.age";
      path = "${config.xdg.dataHome}/secrets/openrouter-pi";
    };

    programs.pi-coding-agent = {
      enable = true;
      package = pkgs-unstable.pi-coding-agent;

      settings = {
        defaultProvider = "openrouter";
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

    # uncomment and test after worktrunk update to v0.80.0
    # home.file."${config.programs.pi-coding-agent.configDir}/extensions/worktrunk.ts" = {
    #   source = "${pkgs-unstable.worktrunk}/share/worktrunk/extensions/pi.ts";
    #   force = true;
    # };
  }
