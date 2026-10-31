{mylib, ...}: {
  imports = [
    (mylib.relativeToRoot "hosts/mbair/features.nix") # global feature flags
    ../../darwin
  ];

  # Just(1) reads this to resolve the hostname.
  home.sessionVariables.HOSTNAME = "mbair";

  # home manager specific feature flags
  features = {
    ai.enable = true;
    theme.catppuccin.enable = true;
    cli = {
      neovim.enable = true;
      git.enable = true;
      git.signing.enable = true;
      mitmproxy.enable = false;
      starship.enable = true;
      tldr.enable = true;
      atuin.enable = true;
      direnv.enable = true;
      eza.enable = true;
      fastfetch.enable = true;
      zoxide.enable = true;
      pay-respects.enable = true;
      herdr.enable = true;
      btop.enable = true;
      superfile.enable = true;
      tuxedo.enable = true;
    };
    desktop = {
      zed.enable = true;
      wallpapers.enable = true;
      ghostty.enable = true;
      kitty.enable = true;
    };
    secrets.enable = true;
  };
}
