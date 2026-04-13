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
    };
  };
}
