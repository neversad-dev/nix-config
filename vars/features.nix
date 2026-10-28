{lib, ...}:
with lib; {
  options = {
    features = {
      development = {
        cursor.enable = mkEnableOption "Cursor editor configurations";
        vscode.enable = mkEnableOption "VSCode configurations";
        android.enable = mkEnableOption "Android development";
      };
      gaming.enable = mkEnableOption "Gaming-related packages";
      stayAwake.enable = mkEnableOption "Stay-awake (caffeinate) configuration";
      theme = {
        # Global: gates the catppuccin HM module (home/base/tui/catppuccin.nix),
        # so every host themes or not from this single switch.
        catppuccin.enable = mkEnableOption "Catppuccin theming (global)";
      };
    };
  };
}
