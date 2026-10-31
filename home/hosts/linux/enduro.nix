{...}: {
  imports = [
    ../../linux/gui.nix
  ];

  targets.genericLinux.enable = true;

  # Just(1) reads this to resolve the hostname.
  home.sessionVariables.HOSTNAME = "enduro";

  features = {
    theme.catppuccin.enable = true;
    cli = {
      neovim.enable = true;
      starship.enable = true;
      tldr.enable = true;
      atuin.enable = true;
      btop.enable = true;
      direnv.enable = true;
      eza.enable = true;
      fastfetch.enable = true;
      herdr.enable = true;
      pay-respects.enable = true;
      superfile.enable = true;
      tuxedo.enable = true;
      zoxide.enable = true;
    };
    desktop = {
      zed.enable = true;
      wallpapers.enable = false;
      ghostty.enable = false;
      kitty.enable = true;
    };
    secrets.enable = true;
  };
}
