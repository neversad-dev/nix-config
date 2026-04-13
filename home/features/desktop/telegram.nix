# Telegram Desktop (opt-in)
{
  config,
  lib,
  pkgs,
  ...
}: with lib; let
  cfg = config.features.desktop.telegram;
in {
  options.features.desktop.telegram.enable = mkEnableOption "Telegram Desktop";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      telegram-desktop
    ];
  };
}
