{lib, ...}: {
  relativeToRoot = lib.path.append ../.;

  scanPaths = path:
    builtins.map
    (f: (path + "/${f}"))
    (builtins.attrNames
      (lib.attrsets.filterAttrs
        (
          path: _type:
            (
              (_type == "directory") # include directories
              && !lib.strings.hasPrefix "_" path # ignore directories starting with _
            )
            || (
              (path != "default.nix") # ignore default.nix
              && (lib.strings.hasSuffix ".nix" path) # include .nix files
            )
        )
        (builtins.readDir path)));
}
