# GUI apps on macOS do not inherit home.sessionVariables. Inject JAVA_HOME (and a minimal
# PATH) into the GUI session at login. JetBrains/Rider often spawn Gradle with an environment
# where PATH is empty or Nix-only; without /usr/bin, gradlew fails on basename/uname/dirname
# before Java runs.
{
  config,
  lib,
  pkgs,
  ...
}: let
  javaHome = config.development.android.javaHome;
  setJavaHome = pkgs.writeShellScript "darwin-set-java-home-gui" ''
    set -eu
    java_home=${lib.escapeShellArg javaHome}
    /bin/launchctl setenv JAVA_HOME "$java_home"

    # gradlew and many scripts expect POSIX tools in /usr/bin
    base_path="$java_home/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    existing="$(/bin/launchctl getenv PATH 2>/dev/null || true)"
    if [ -n "$existing" ]; then
      /bin/launchctl setenv PATH "$base_path:$existing"
    else
      /bin/launchctl setenv PATH "$base_path"
    fi
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
