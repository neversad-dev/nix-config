{mylib, ...}: {
  imports = [
    (mylib.relativeToRoot "hosts/mbair/config.nix")
    ./home.nix
    ../common
    ../features/cli
    ../features/desktop
    ../features/darwin
    ../features/development
  ];
}
