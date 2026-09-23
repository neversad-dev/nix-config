{
  pkgs,
  pkgs-unstable,
  ...
}: let
  configPath =
    if pkgs.stdenv.isLinux
    then ".config/superfile/config.toml"
    else "Library/Application Support/superfile/config.toml";
  hotkeysPath =
    if pkgs.stdenv.isLinux
    then ".config/superfile/hotkeys.toml"
    else "Library/Application Support/superfile/hotkeys.toml";
in {
  home.packages = with pkgs-unstable; [
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
}
