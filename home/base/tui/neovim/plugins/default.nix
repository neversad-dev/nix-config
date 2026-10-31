# nvf's `programs.nvf.settings` submodule only injects pkgs/lib/inputs,
# so import the local scanPaths helper directly instead of relying on mylib.
{lib, ...}: let
  scanPaths = import ../../../../../lib/scan-paths.nix {inherit lib;};
in {
  imports = scanPaths ./.;
}
