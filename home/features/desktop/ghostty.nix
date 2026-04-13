# Ghostty: Nix package on Linux; on macOS only config (install Ghostty via Homebrew).
{
  config,
  lib,
  mylib,
  pkgs,
  inputs,
  ...
}: with lib; let
  cfg = config.features.desktop.ghostty;
  defaultConfig = ''
    theme = "Catppuccin Mocha"

    window-inherit-working-directory = "true"

    font-family = "Maple Mono NF CN"

    font-size = 15

    background-opacity = 0.93

    # only supported on macOS

    background-blur-radius = 10

    scrollback-limit = 20000

    macos-titlebar-style = "hidden"

  '';
in {
  options.features.desktop.ghostty.enable = mkEnableOption ''
    Ghostty terminal: installs the Nix package on Linux; on macOS only writes ~/.config/ghostty/config (use Homebrew for the app)
  '';

  config = mkIf cfg.enable (mkMerge [
    {
      # Copy config to create an editable file (not a symlink)
      home.activation.copyGhosttyConfig = mylib.mkEditableConfig {
        name = "Ghostty";
        configPath = "$HOME/.config/ghostty/config";
        content = defaultConfig;
        pkgs = pkgs;
      };
    }
    (mkIf pkgs.stdenv.hostPlatform.isLinux {
      home.packages = [
        inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    })
  ]);
}
