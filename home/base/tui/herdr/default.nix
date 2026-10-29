{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:
with lib; {
  imports = mylib.scanPaths ./.;

  # programs.herdr options are provided by upstream Home Manager's
  # modules/programs/herdr.nix — do not re-declare them here (causes a
  # duplicate-option eval error on recent HM).
  options.features.cli.herdr.enable = mkEnableOption "herdr terminal manager";

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
