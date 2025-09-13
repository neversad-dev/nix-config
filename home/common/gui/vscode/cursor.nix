{
  pkgs,
  mylib,
  ...
}: let
  commonSettings = (import ./common.nix {inherit pkgs;}).commonSettings;
  settingsJson = builtins.toJSON commonSettings;
in {
  # Copy settings to create an editable file (not a symlink)
  home.activation.copyCursorSettings = mylib.mkEditableConfig {
    name = "Cursor";
    configPath = "$HOME/Library/Application Support/Cursor/User/settings.json";
    content = settingsJson;
    pkgs = pkgs;
    isJson = true;
  };
}
