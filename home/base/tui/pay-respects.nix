# Suggest fixes after a mistyped command (thefuck-style)
{
  config,
  lib,
  pkgs,
  ...
}: {
  options.features.cli.pay-respects.enable =
    lib.mkEnableOption "pay-respects command corrector";

  config = lib.mkIf config.features.cli.pay-respects.enable {
    home.packages = with pkgs; [
      pay-respects
    ];

    programs.zsh.initContent = ''
      eval "$(pay-respects zsh --alias)"
    '';
  };
}
