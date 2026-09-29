{
  lib,
  mylib,
  ...
}: {
  options.features.ai.enable = lib.mkEnableOption "AI features";

  imports =
    mylib.scanPaths ./.;
}
