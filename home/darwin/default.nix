{mylib, ...}: {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      ../base/home.nix
      ../base/core
      ../base/tui
      ../base/gui
    ];
}
