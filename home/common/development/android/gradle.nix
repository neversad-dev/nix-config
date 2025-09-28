{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.development.android.enable {
    programs.gradle = {
      enable = true;
      package = pkgs.gradle_8;

      settings = {
        # Memory & GC tuning
        "org.gradle.jvmargs" = "-Xmx12288m -XX:+UseG1GC -Dfile.encoding=UTF-8";

        # Performance optimizations
        "org.gradle.parallel" = true;
        "org.gradle.daemon" = true;
        "org.gradle.configureondemand" = true;
        "org.gradle.caching" = true;

        # Kotlin-specific optimization
        "kotlin.incremental.useClasspathSnapshot" = true;
        "kotlin.daemon.jvmargs" = "-Xmx4096m";

        # Ensure correct JDK (Zulu 17 is safest for Android/Gradle)
        "org.gradle.java.home" = "${pkgs.zulu17}";
      };
    };

    # Make sure git is in PATH for Gradle
    home.sessionPath = [
      "${pkgs.git}/bin"
    ];
  };
}
