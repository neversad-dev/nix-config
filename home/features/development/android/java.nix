{
  config,
  lib,
  ...
}: let
  javaHome = config.features.development.android.javaHome;
in {
  config = lib.mkIf config.features.development.android.enable {
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
