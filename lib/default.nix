{lib, ...}:
{
  scanPaths = import ./scan-paths.nix {inherit lib;};
}
// (import ./editable-config.nix {inherit lib;})
