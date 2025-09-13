{
  mylib,
  pkgs,
  ...
}: let
  defaultConfig = ''
    theme = catppuccin-mocha

    window-inherit-working-directory = "true"

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
