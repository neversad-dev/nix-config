{
  lib,
  mylib,
  ...
}: {
  options.features.cli.git.enable = lib.mkEnableOption "Git (delta, LFS, aliases)";

  imports = mylib.scanPaths ./.;
}
