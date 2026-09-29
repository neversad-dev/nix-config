{
  config,
  lib,
  pkgs-unstable,
  nix-secrets,
  ...
}:
with lib; let
  cfg = config.features.ai;
in
  mkIf cfg.enable {
    age.secrets."openrouter-pi" = {
      file = "${nix-secrets}/shared/openrouter-pi.age";
      path = "${config.xdg.dataHome}/secrets/openrouter-pi";
    };

    home.packages = [
      pkgs-unstable.pi-coding-agent
    ];

    home.file.".pi/agent/auth.json" = {
      text = builtins.toJSON {
        openrouter = {
          type = "api_key";
          key = "!cat ${config.age.secrets."openrouter-pi".path}";
        };
      };
      force = true;
    };
  }
