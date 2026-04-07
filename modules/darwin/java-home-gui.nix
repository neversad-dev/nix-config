# GUI apps on macOS do not inherit home.sessionVariables. Inject JAVA_HOME into the GUI
# session at login so Android Studio’s “JAVA_HOME” Gradle JDK matches the CLI.
{
  config,
  lib,
  pkgs,
  ...
}: let
  javaHome = config.development.android.javaHome;
  setJavaHome = pkgs.writeShellScript "darwin-set-java-home-gui" ''
    set -eu
    /bin/launchctl setenv JAVA_HOME ${lib.escapeShellArg javaHome}
  '';
in {
  config = lib.mkIf (config.development.android.enable && pkgs.stdenv.hostPlatform.isDarwin) {
    launchd.user.agents.set-java-home-for-gui = {
      serviceConfig = {
        ProgramArguments = ["${setJavaHome}"];
        RunAtLoad = true;
      };
    };
  };
}
