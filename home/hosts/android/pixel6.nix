{...}: {
  imports = [
    ../../android
  ];

  # Home manager specific feature flags — all disabled for now.
  # Enable selectively after testing on device.
  features = {
    ai.enable = false;
    theme.catppuccin.enable = true;
    cli = {
      neovim.enable = true; # language packages aliased in flake.nix
      git.enable = true;
      git.signing.enable = false;
      mitmproxy.enable = false;
      starship.enable = true;
      tldr.enable = false;
      atuin.enable = true;
      direnv.enable = true;
      eza.enable = true;
      fastfetch.enable = true;
      zoxide.enable = true;
      pay-respects.enable = false;
      herdr.enable = false;
      btop.enable = false;
      superfile.enable = true;
      tuxedo.enable = true;
    };
    secrets.enable = false;
  };
}
