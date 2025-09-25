{
  pkgs,
  mylib,
  lib,
  config,
  ...
}: let
  commonSettings = (import ./common.nix {inherit pkgs;}).commonSettings;
  settingsJson = builtins.toJSON commonSettings;
in {
  config = lib.mkIf config.cursor.enable {
    # Copy settings to create an editable file (not a symlink)
    home.activation.copyCursorSettings = mylib.mkEditableConfig {
      name = "Cursor";
      configPath = "$HOME/Library/Application Support/Cursor/User/settings.json";
      content = settingsJson;
      pkgs = pkgs;
      isJson = true;
    };
  };
}
