{
  config,
  lib,
  pkgs,
  mylib,
  ...
}:
with lib; let
  # Newer Home Manager provides its own modules/programs/herdr.nix —
  # re-declaring there causes a duplicate-option eval error. HM 24.05
  # (used by nix-on-droid) has no herdr module, so declare a polyfill
  # there. Gate on lib.version. Remove once nix-on-droid ships newer HM.
  herdrPolyfill = lib.versionOlder lib.version "25.05";
in {
  imports = mylib.scanPaths ./.;

  options =
    {
      features.cli.herdr.enable = mkEnableOption "herdr terminal manager";
    }
    // (
      if herdrPolyfill
      then {
        programs.herdr = {
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
            description = "Settings for herdr, passed as config.";
          };
        };
      }
      else {}
    );

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
