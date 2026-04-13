{mylib, ...}: {
  imports =
    (mylib.scanPaths ./.)
    ++ [
      (mylib.relativeToRoot "vars/features.nix")
    ];
}
