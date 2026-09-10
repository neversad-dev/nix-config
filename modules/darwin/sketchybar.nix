{
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    homebrew.brews = ["sketchybar"];

    fonts.packages = with pkgs; [
      sketchybar-app-font
      nerd-fonts.symbols-only
    ];
  };
}
