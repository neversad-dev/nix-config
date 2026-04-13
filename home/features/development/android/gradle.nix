{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.features.development.android.enable {
    programs.gradle = {
      enable = true;
      package = pkgs.gradle;

      settings =
        {
          # Memory & GC tuning
          "org.gradle.jvmargs" = "-Xmx12288m -XX:+UseG1GC -Dfile.encoding=UTF-8";
        }
        // lib.optionalAttrs pkgs.stdenv.isDarwin {
          "org.gradle.java.home" = config.features.development.android.javaHome;
        };
    };
  };
}
