{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.git.extended;
in {
  config = mkIf cfg.enable {
    programs.worktrunk = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      settings = {
      };
    };
  };
}
