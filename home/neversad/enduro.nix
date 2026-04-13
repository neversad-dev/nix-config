{...}: {
  imports = [
    ./home.nix
    ../common
    ../features/cli
    ../features/desktop
    ../features/linux
  ];

  targets.genericLinux.enable = true;

  features = {
    cli = {
      neovim.enable = true;
    };
  };
}
