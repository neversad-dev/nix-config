{mylib, ...}: {
  imports = [
    (mylib.relativeToRoot "hosts/mbair/features.nix") # global feature flags
    ./home.nix
    ../common
    ../features/cli
    ../features/desktop
    ../features/darwin
    ../features/development
  ];

  # home manager specific feature flags
  features = {
    cli = {
      neovim.enable = true;
      git.enable = true;
      mitmproxy.enable = false;
      starship.enable = true;
      tldr.enable = true;
      tmux.enable = false;
    };
    desktop = {
      zed.enable = false;
      wallpapers.enable = true;
      telegram.enable = true;
      ghostty.enable = true;
      kitty.enable = true;
    };
    development = {
      nix.enable = true;
    };
  };
}
