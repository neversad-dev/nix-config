{
  config,
  lib,
  mylib,
  ...
}: {
  imports = mylib.scanPaths ./.;

  options.features.cli.herdr.enable = lib.mkEnableOption "herdr terminal manager";

  config = lib.mkIf config.features.cli.herdr.enable {
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
