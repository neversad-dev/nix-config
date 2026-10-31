{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.git;
in {
  config = mkIf cfg.enable {
    programs.worktrunk = {
      enable = true;
      enableZshIntegration = true;
      settings = {
      };
    };
  };
}
