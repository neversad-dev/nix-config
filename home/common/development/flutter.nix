{
  lib,
  pkgs,
  config,
  mylib,
  ...
}: let
  # Flutter version configuration - update this to change Flutter version
  flutterVersion = "3.35.4";
  flutterDir = "$HOME/flutter_${flutterVersion}";
in {
  config = lib.mkIf config.development.flutter.enable {
    # Install Flutter via git clone to specific version
    home.activation.installFlutter = lib.hm.dag.entryAfter ["writeBoundary"] ''
      FLUTTER_DIR="${flutterDir}"

      # Clean up old Flutter versions
      echo "Cleaning up old Flutter installations..."
      for old_flutter in "$HOME"/flutter_*; do
        if [ -d "$old_flutter" ] && [ "$old_flutter" != "$FLUTTER_DIR" ]; then
          echo "Removing old Flutter installation: $old_flutter"
          rm -rf "$old_flutter"
        fi
      done

      if [ ! -d "$FLUTTER_DIR" ]; then
        echo "Installing Flutter ${flutterVersion}..."
        ${pkgs.git}/bin/git clone --branch ${flutterVersion} --depth 1 https://github.com/flutter/flutter.git "$FLUTTER_DIR"
        echo "Flutter ${flutterVersion} installed to $FLUTTER_DIR"
      else
        echo "Flutter ${flutterVersion} already installed at $FLUTTER_DIR"
      fi

      # Ensure Flutter is executable
      chmod +x "$FLUTTER_DIR/bin/flutter"
      chmod +x "$FLUTTER_DIR/bin/dart"
    '';

    # Set up Flutter environment variables
    home.sessionVariables = {
      # Flutter paths
      FLUTTER_ROOT = flutterDir;
      FLUTTER_HOME = flutterDir;

      # Configure Flutter to use our Zulu JDK
      JAVA_HOME_FLUTTER = "${pkgs.zulu17}";

      # Fix upstream repository warning
      FLUTTER_GIT_URL = "unknown source";
    };

    # Add Flutter to PATH
    home.sessionPath = [
      "${flutterDir}/bin"
    ];

    home.activation.copyFlutterSettings = mylib.mkEditableConfig {
      name = "Flutter";
      configPath = "$HOME/.config/flutter/settings";
      content = ''
        {
          "enable-analytics": false,
          "crash-reporting": false,
          "jdk-dir": "${pkgs.zulu17}"
        }
      '';
      pkgs = pkgs;
    };
  };
}
