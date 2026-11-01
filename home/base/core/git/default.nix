{
  lib,
  mylib,
  ...
}: {
  imports = mylib.scanPaths ./.;
  # Two independent flags:
  # - core.enable: core Git configuration (identity, ignores, aliases, commit
  #   template/hooks). The git package itself is NOT gated: programs.git is
  #   always enabled so a bare git binary is always available.
  # - extended.enable: the optional TUI Git bundle (delta, lazygit, worktrunk).
  options.features.cli.git = {
    core.enable = lib.mkEnableOption "core Git configuration (identity, ignores, aliases, commit template)";
    extended.enable = lib.mkEnableOption "Git extras (delta, lazygit, worktrunk)";
    signing.enable = lib.mkEnableOption "SSH commit signing";
  };
}
