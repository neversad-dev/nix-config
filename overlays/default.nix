{mylib, ...}: {
  nixpkgs.overlays =
    builtins.map import (mylib.scanPaths ./.);
}
