{
  lib,
  mylib,
  ...
}: {
  options.features.ai.enable = lib.mkEnableOption "Ai features";

  imports =
    mylib.scanPaths ./.;
}
