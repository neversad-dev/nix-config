{
  mylib,
  pkgs,
  ...
}: let
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
  # Copy config to create an editable file (not a symlink)
  home.activation.copyGhosttyConfig = mylib.mkEditableConfig {
    name = "Ghostty";
    configPath = "$HOME/.config/ghostty/config";
    content = defaultConfig;
    pkgs = pkgs;
  };
}
