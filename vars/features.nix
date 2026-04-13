{lib, ...}:
with lib; {
  options = {
    features = {
      development = {
        cursor.enable = mkEnableOption "Cursor editor configurations";
        vscode.enable = mkEnableOption "VSCode configurations";
        flutter.enable = mkEnableOption "Flutter";
        ruby.enable = mkEnableOption "Ruby";
        android.enable = mkEnableOption "Android development";
        android.javaHome = mkOption {
          type = types.str;
          default = "/Applications/Android Studio.app/Contents/jbr/Contents/Home";
          description = ''
            JAVA_HOME for Android tooling. Shells pick this up via Home Manager; on macOS a
            Launch Agent also runs launchctl setenv so GUI apps (e.g. Android Studio) see it.
            Override per host with a store path (e.g. OpenJDK 17 via pkgs.jdk17) when the module has pkgs in scope.
          '';
        };
      };
      gaming.enable = mkEnableOption "Gaming-related packages";
      stayAwake.enable = mkEnableOption "Stay-awake (caffeinate) configuration";
    };
  };
}
