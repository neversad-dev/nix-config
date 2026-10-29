# Tuxedo — fast, keyboard-driven terminal UI for todo.txt
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.tuxedo;
  todoDir = "${config.home.homeDirectory}/.todo";
in {
  options.features.cli.tuxedo.enable = mkEnableOption "tuxedo todo.txt TUI";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      tuxedo
    ];

    home.sessionVariables = {
      TODO_DIR = todoDir;
      TUXEDO_NO_UPDATE_CHECK = "1";
    };

    # Force-managed, read-only config. All changes must go through Nix.
    home.file.".config/tuxedo/config.toml" = {
      force = true;
      source = ./config.toml;
    };

    # Ensure ~/.todo exists with 0700 permissions (owner-only access)
    home.activation.tuxedoSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "${todoDir}"
      $DRY_RUN_CMD chmod $VERBOSE_ARG 700 "${todoDir}"
    '';
  };
}
