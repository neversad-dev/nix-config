{
  config,
  lib,
  pkgs-unstable,
  ...
}:
with lib; let
  cfg = config.features.cli.git;
in {
  config = mkIf cfg.enable {
    programs.worktrunk = {
      enable = true;
      package = pkgs-unstable.worktrunk;
      enableZshIntegration = true;
      settings = {
      };
    };
  };
}
