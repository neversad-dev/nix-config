{
  lib,
  pkgs,
  mylib,
  ...
}: {
  home.activation.sketchybar = lib.hm.dag.entryAfter ["writeBoundary"] "${pkgs.sketchybar}/bin/sketchybar --reload";

  # Use mkEditableConfigDir to make all sketchybar files editable
  home.activation.copySketchybarConfig = mylib.mkEditableConfigDir {
    name = "Sketchybar";
    configDir = "$HOME/.config/sketchybar";
    sourceDir = ./config;
    pkgs = pkgs;
  };
}
