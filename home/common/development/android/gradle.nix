{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.development.android.enable {
    # Install Gradle via Home Manager
    programs.gradle = {
      enable = true;
      package = pkgs.gradle_8;

      settings = {
        "org.gradle.caching" = true;
        "org.gradle.parallel" = true;
        "org.gradle.jvmargs" = "-XX:MaxMetaspaceSize=384m -Djava.library.path=${pkgs.git}/bin";
        "org.gradle.java.home" = "${pkgs.zulu21}";
        "org.gradle.daemon" = true;
      };
    };

    # Ensure git is available for Gradle
    home.sessionPath = [
      "${pkgs.git}/bin"
    ];
  };
}
