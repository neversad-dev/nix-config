{...}: {
  imports = [
    ../neversad/home.nix
    ../common
    ../features/cli
    ../features/desktop
    ../features/linux
  ];

  targets.genericLinux.enable = true;
}
