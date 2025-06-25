{lib, ...}: {
  options = {
    personal.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Personal only Configurations";
    };
  };
}
