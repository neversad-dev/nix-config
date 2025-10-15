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
