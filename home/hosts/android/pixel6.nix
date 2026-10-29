{
  config,
  lib,
  pkgs,
  mylib,
  ...
}: {
  imports = [
    ../../android
  ];

  # Home manager specific feature flags — all disabled for now.
  # Enable selectively after testing on device.
  features = {
    ai.enable = false;
    theme.catppuccin.enable = false;
    cli = {
      neovim.enable = false;
      git.enable = true;
      git.signing.enable = false;
      mitmproxy.enable = false;
      starship.enable = true;
      tldr.enable = false;
      atuin.enable = false;
      direnv.enable = false;
      eza.enable = false;
      fastfetch.enable = false;
      zoxide.enable = false;
      pay-respects.enable = false;
      herdr.enable = false;
      btop.enable = false;
      superfile.enable = false;
      tuxedo.enable = false;
    };
    desktop = {
      zed.enable = false;
      wallpapers.enable = false;
      ghostty.enable = false;
      kitty.enable = false;
    };
    secrets.enable = false;
  };
}
