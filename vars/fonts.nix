{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.myFonts = {
    main = mkOption {
      type = types.str;
      default = "Menlo";
      description = "Main monospace font.";
    };

    mono = mkOption {
      type = types.str;
      default = "Menlo";
      description = "Strictly monospace font.";
    };

    propo = mkOption {
      type = types.str;
      default = "Menlo";
      description = "Proportional font variant.";
    };
  };
}
