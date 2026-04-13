# Wallpaper collection symlinked into ~/Pictures (opt-in)
{
  config,
  lib,
  wallpapers,
  ...
}:
with lib; let
  cfg = config.features.desktop.wallpapers;
in {
  options.features.desktop.wallpapers.enable = mkEnableOption "wallpapers flake checkout in ~/Pictures/Wallpapers";

  config = mkIf cfg.enable {
    home.file."Pictures/Wallpapers".source = "${wallpapers}";
  };
}
