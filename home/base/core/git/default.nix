{
  lib,
  mylib,
  ...
}: {
  imports = mylib.scanPaths ./.;
  # This flag controls the optional TUI Git bundle, not basic Git.
  options.features.cli.git = {
    enable = lib.mkEnableOption "Git extras (delta, lazygit, worktrunk)";
    signing.enable = lib.mkEnableOption "SSH commit signing";
  };
}
