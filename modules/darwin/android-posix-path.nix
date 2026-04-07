# Ensure POSIX tool dirs are on the system PATH early (belt-and-suspenders with launchctl).
{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.development.android.enable && pkgs.stdenv.hostPlatform.isDarwin) {
    environment.systemPath = lib.mkBefore [
      "/usr/bin"
      "/bin"
      "/usr/sbin"
      "/sbin"
    ];
  };
}
