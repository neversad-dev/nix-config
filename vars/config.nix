{lib, ...}: {
  options = {
    development = lib.mkOption {
      type = lib.types.submodule {
        options = {
          cursor.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Cursor Editor Configurations";
          };
          vscode.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable VSCode Configurations";
          };
          android.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Android Configurations";
          };
          android.javaHome = lib.mkOption {
            type = lib.types.str;
            default = "/Applications/Android Studio.app/Contents/jbr/Contents/Home";
            description = ''
              JAVA_HOME for Android tooling. Shells pick this up via Home Manager; on macOS a
              Launch Agent also runs launchctl setenv so GUI apps (e.g. Android Studio) see it.
              Override per host for OpenJDK 17 from Nix, e.g. `javaHome = "''${pkgs.jdk17}";` (module needs `pkgs`).
            '';
          };
          flutter.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Flutter Configurations";
          };
          ruby.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Ruby Configurations";
          };
        };
      };
      default = {};
      description = "Development tool configurations";
    };
    stay-awake.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Stay Awake Configurations";
    };
    gaming.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Gaming Configurations";
    };
  };
}
