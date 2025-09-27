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
        };
      };
      default = {};
      description = "Development tool configurations";
    };
    gaming.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Gaming Configurations";
    };
  };
}
