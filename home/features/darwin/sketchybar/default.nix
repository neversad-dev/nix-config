{
  lib,
  pkgs,
  mylib,
  config,
  ...
}: {
  home.file.".config/sketchybar/fonts.sh".text = ''
    export SKETCHYBAR_FONT="${config.myFonts.main}"
  '';

  # Use mkEditableConfigDir to make all sketchybar files editable
  home.activation.copySketchybarConfig = mylib.mkEditableConfigDir {
    name = "Sketchybar";
    configDir = "$HOME/.config/sketchybar";
    sourceDir = ./config;
    pkgs = pkgs;
  };
}
