{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:
with lib; {
  imports = mylib.scanPaths ./.;

  options.features.cli.herdr.enable = mkEnableOption "herdr terminal manager";

  options.programs.herdr = {
    enable = mkEnableOption "herdr terminal manager";
    package = mkOption {
      type = types.package;
      default = pkgs.herdr;
      defaultText = literalExpression "pkgs.herdr";
      description = "The herdr package to use.";
    };
    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Settings for herdr, passed as JSON config.";
    };
  };

  config = mkIf config.features.cli.herdr.enable {
    programs.herdr = {
      enable = true;
      settings = {
        onboarding = false;
        theme = {
          name = "catppuccin";
        };
        ui = {
          sound = {
            enabled = false;
          };
          toast = {
            delivery = "system";
          };
          status_indicators = "symbols";
        };
        keys = {};
      };
    };
  };
}
