{...}: {
  imports = [
    ./home.nix
    ../common
    ../features/cli
    ../features/desktop
    ../features/linux
    ../features/development
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
      telegram.enable = false;
      ghostty.enable = true;
      kitty.enable = true;
    };
    development = {
      nix.enable = true;
    };
  };
}
