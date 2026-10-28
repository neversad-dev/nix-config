{
  lib,
  mylib,
  ...
}: {
  options.features.cli.git = {
    enable = lib.mkEnableOption "Git (delta, LFS, aliases)";
    signing.enable = lib.mkEnableOption "SSH commit signing";
  };

  imports = mylib.scanPaths ./.;
}
