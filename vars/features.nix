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
    };
  };
}
