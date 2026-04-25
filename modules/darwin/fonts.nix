{
  lib,
  pkgs,
  ...
}:
with lib; {
  config.fonts.packages = with pkgs; [
    sketchybar-app-font
  ];
}
