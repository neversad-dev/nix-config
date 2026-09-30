# Tuxedo — fast, keyboard-driven terminal UI for todo.txt
{
  config,
  lib,
  pkgs-unstable,
  ...
}: let
  todoDir = "${config.home.homeDirectory}/.todo";
in {
  home.packages = with pkgs-unstable; [
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
}
