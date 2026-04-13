# JetBrains (Rider / Android Studio) often runs gradlew with PATH cleared. launchctl cannot
# fix that subprocess. We keep a stable symlink to the configured JDK and generate two lines
# to paste into Settings | Build | Gradle | Environment variables (PATH + JAVA_HOME).
{
  config,
  lib,
  pkgs,
  ...
}: let
  javaHome = config.features.development.android.javaHome;
  homeDir = config.home.homeDirectory;
  jdkLink = "${homeDir}/.local/state/android-jdk-home";
in {
  config = lib.mkIf config.features.development.android.enable {
    home.activation.androidJdkSymlink = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ${lib.escapeShellArg "${homeDir}/.local/state"}
      ln -sfn ${lib.escapeShellArg javaHome} ${lib.escapeShellArg jdkLink}
    '';

    home.file.".config/jetbrains-android-gradle.env".text =
      "PATH=${jdkLink}/bin:/usr/bin:/bin:/usr/sbin:/sbin\n"
      + "JAVA_HOME=${jdkLink}\n";
  };
}
