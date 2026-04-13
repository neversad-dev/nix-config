{mylib, ...}: {
  imports = [
    (mylib.relativeToRoot "hosts/mbair/config.nix") # global feature flags
    ./home.nix
    ../common
    ../features/cli
    ../features/desktop
    ../features/darwin
    ../features/development
  ];

  features = {
    cli = {
      neovim.enable = true;
    };
  };
}
