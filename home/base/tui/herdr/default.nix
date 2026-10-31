{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:
with lib; {
  imports = mylib.scanPaths ./.;

  # programs.herdr options come from upstream HM's modules/programs/herdr.nix.
  # On HM 24.05 (nix-on-droid) they are polyfilled in home/android/compat.nix.
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
