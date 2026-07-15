{
  lib,
  pkgs,
  mylib,
  ...
}: {
  # Use mkEditableConfigDir to make all sketchybar files editable
  home.activation.copySketchybarConfig = mylib.mkEditableConfigDir {
    name = "Sketchybar";
    configDir = "$HOME/.config/sketchybar";
    sourceDir = ./config;
    pkgs = pkgs;
  };
}
