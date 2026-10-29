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
      neovim = {
        enable = true;
        # nvf language/debugger presets need packages missing in nixpkgs-24.05.
        languages.enable = true; # with the 24.05-missing packages aliased above
        debugger.enable = false;
      };
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
      superfile.enable = false;
      tuxedo.enable = false;
    };
    secrets.enable = false;
  };
}
