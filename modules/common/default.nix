{mylib, ...}: {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      (mylib.relativeToRoot "vars/config.nix")
    ];
}
