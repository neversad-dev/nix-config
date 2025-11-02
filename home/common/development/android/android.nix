# Hybrid Android setup: Declarative Nix + Android Studio compatibility
{
  config,
  lib,
  pkgs,
  ...
}: let
  # NDK version (easily configurable)
  ndkVersion = "27.0.12077973";

  # Android SDK installation path (platform-specific)
  androidSdkPath =
    if pkgs.stdenv.isDarwin
    then "$HOME/Library/Android/sdk"
    else "$HOME/Android/Sdk";

  # Declarative Android SDK for consistent command-line development
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    # Core tools for command-line development
    cmdLineToolsVersion = "19.0";
    platformToolsVersion = "36.0.0"; # adb, fastboot
    buildToolsVersions = ["36.0.0"];
    platformVersions = ["36"];

    # NDK for native development
    includeNDK = true;
    ndkVersions = [ndkVersion];

    # Include emulator and system images
    includeEmulator = true;
    emulatorVersion = "36.1.9";
    includeSystemImages = true;
    systemImageTypes = ["google_apis"];
    # Only download system images for current architecture (saves disk space & build time)
    abiVersions =
      if pkgs.stdenv.isAarch64
      then ["arm64-v8a"]
      else ["x86_64"];

    # Include Android sources for debugging and development
    includeSources = true;
  };
in {
  config = lib.mkIf config.development.android.enable {
    # Accept Android SDK license
    nixpkgs.config.android_sdk.accept_license = true;

    # Install Nix Android SDK
    home.packages = [
      androidComposition.androidsdk
    ];

    # Environment variables point to Android Studio's location
    home.sessionVariables = {
      ANDROID_HOME = androidSdkPath;
      ANDROID_SDK_ROOT = androidSdkPath;
      ANDROID_NDK_ROOT = "${androidSdkPath}/ndk/${ndkVersion}";
      ANDROID_USER_HOME = "${config.home.homeDirectory}/.android";
      ANDROID_AVD_HOME = "${config.home.homeDirectory}/.android/avd";
    };

    # Add Android Studio's SDK to PATH (for command-line consistency)
    home.sessionPath = [
      "${androidSdkPath}/platform-tools"
      "${androidSdkPath}/cmdline-tools/latest/bin"
      "${androidSdkPath}/emulator"
      "${androidSdkPath}/ndk/${ndkVersion}"
    ];

    # Sync Nix Android SDK to Android Studio's expected location
    home.activation.syncAndroidSdk = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Ensure Android Studio SDK directory exists
      mkdir -p "${androidSdkPath}"
      mkdir -p "${androidSdkPath}/licenses"

      # Copy/update Nix SDK components to Android Studio location
      echo "Syncing Nix Android SDK to Android Studio location..."

      # Copy core components from Nix (resolving all symlinks)
      for component in build-tools cmdline-tools emulator platform-tools platforms system-images sources skins; do
        if [ -d "${androidComposition.androidsdk}/libexec/android-sdk/$component" ]; then
          echo "Syncing $component..."
          rm -rf "${androidSdkPath}/$component"
          # Use cp -rL to follow symlinks and copy actual files
          cp -rL "${androidComposition.androidsdk}/libexec/android-sdk/$component" "${androidSdkPath}/"
          # Make copied files writable
          chmod -R u+w "${androidSdkPath}/$component"
        fi
      done

      # Copy NDK if available (resolving symlinks)
      if [ -d "${androidComposition.androidsdk}/libexec/android-sdk/ndk-bundle" ]; then
        echo "Syncing NDK..."
        mkdir -p "${androidSdkPath}/ndk"
        rm -rf "${androidSdkPath}/ndk/${ndkVersion}"
        # Use cp -rL to follow symlinks and copy actual files
        cp -rL "${androidComposition.androidsdk}/libexec/android-sdk/ndk-bundle" "${androidSdkPath}/ndk/${ndkVersion}"
        # Make copied NDK files writable
        chmod -R u+w "${androidSdkPath}/ndk/${ndkVersion}"
      fi

      # Copy licenses (resolving symlinks)
      if [ -d "${androidComposition.androidsdk}/libexec/android-sdk/licenses" ]; then
        cp -rL "${androidComposition.androidsdk}/libexec/android-sdk/licenses/"* "${androidSdkPath}/licenses/" 2>/dev/null || true
      fi

      # Ensure skins directory exists and is accessible
      if [ -d "${androidSdkPath}/skins" ]; then
        echo "✓ Emulator skins available at ${androidSdkPath}/skins"
        ls -la "${androidSdkPath}/skins" | head -10
      else
        echo "⚠ Skins directory not found - emulators will use default skins"
      fi

      echo "✓ Nix Android SDK synced to ${androidSdkPath}"
      echo "✓ Android Studio can now download additional components to the same location"
      echo "✓ Command-line tools (adb, etc.) work from both Nix and Android Studio SDK"
      echo "✓ Emulator skins are available for device-specific configurations"
    '';
  };
}
