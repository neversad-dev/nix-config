{
  pkgs,
  mylib,
  lib,
  config,
  ...
}: let
  commonSettings = (import ./common.nix {inherit pkgs;}).commonSettings;
  cursorSettings = commonSettings // {
    "cursor.composer.usageSummaryDisplay" = "always";
  };
  settingsJson = builtins.toJSON cursorSettings;
in {
  config = lib.mkIf config.development.cursor.enable {
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
