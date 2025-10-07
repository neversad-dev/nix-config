{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.development.android.enable {
    programs.gradle = {
      enable = true;
      package = pkgs.gradle;

      settings = {
        # Memory & GC tuning
        "org.gradle.jvmargs" = "-Xmx12288m -XX:+UseG1GC -Dfile.encoding=UTF-8";
      };
    };
  };
}
