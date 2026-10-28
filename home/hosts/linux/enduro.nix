{...}: {
  imports = [
    ../../linux/gui.nix
  ];

  targets.genericLinux.enable = true;

  features = {
    cli = {
      neovim.enable = true;
      starship.enable = true;
      tldr.enable = true;
    };
    desktop = {
      zed.enable = true;
      wallpapers.enable = false;
      ghostty.enable = false;
      kitty.enable = true;
    };
  };
}
