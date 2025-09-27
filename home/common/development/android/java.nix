{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.development.android.enable {
    home = {
      packages = with pkgs; [
        zulu21
      ];
      sessionVariables = {
        JAVA_HOME = "${pkgs.zulu21}";
      };
      sessionPath = [
        "${pkgs.zulu21}/bin"
      ];
    };
  };
}
