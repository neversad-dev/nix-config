{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.superfile;
  configPath =
    if pkgs.stdenv.hostPlatform.isLinux
    then ".config/superfile/config.toml"
    else "Library/Application Support/superfile/config.toml";
  hotkeysPath =
    if pkgs.stdenv.hostPlatform.isLinux
    then ".config/superfile/hotkeys.toml"
    else "Library/Application Support/superfile/hotkeys.toml";
in {
  options.features.cli.superfile.enable = mkEnableOption "superfile TUI file manager";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      superfile
    ];

    home.file = {
      "${configPath}" = {
        source = ./config.toml;
        force = true;
      };

      "${hotkeysPath}" = {
        source = ./hotkeys.toml;
        force = true; # This tells Home Manager to overwrite existing non-symlinked files
      };
    };

    programs.zsh.shellAliases = {
      spf = "superfile";
    };
  };
}
