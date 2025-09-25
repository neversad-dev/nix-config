{lib, ...}: {
  options = {
    cursor.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Cursor Editor Configurations";
    };
    gaming.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Gaming Configurations";
    };
  };
}
