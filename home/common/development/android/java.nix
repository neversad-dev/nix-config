{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.development.android.enable {
    home = {
      packages = with pkgs; [
        zulu17
      ];
      sessionVariables = {
        JAVA_HOME = "${pkgs.zulu17}";
      };
      sessionPath = [
        "${pkgs.zulu17}/bin"
      ];
    };
  };
}
