{
  config,
  lib,
  ...
}: let
  javaHome = config.development.android.javaHome;
in {
  config = lib.mkIf config.development.android.enable {
    home = {
      sessionVariables = {
        JAVA_HOME = javaHome;
      };
      sessionPath = [
        "${javaHome}/bin"
      ];
    };
  };
}
