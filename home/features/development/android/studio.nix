# Android Studio Configuration
# Provides optimized VM options and settings for Android Studio
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.development.android.enable {
    # Android Studio VM options for optimal performance
    home.activation.androidStudioVmoptions = lib.hm.dag.entryAfter ["writeBoundary"] ''
            # VM Options Configuration
            # Memory settings optimized for large Android projects
            vmopts="\
      -Xms2048m
      -Xmx12288m
      -XX:ReservedCodeCacheSize=1024m
      -XX:+UseG1GC
      -XX:+UseStringDeduplication
      -XX:+UseCompressedOops
      -XX:SoftRefLRUPolicyMSPerMB=50
      -XX:+HeapDumpOnOutOfMemoryError
      -Dfile.encoding=UTF-8
      -Dsun.jnu.encoding=UTF-8
      "

            # Android Studio Configuration Directory
            base="$HOME/Library/Application Support/Google"

            # Apply VM options to all Android Studio installations
            if [ -d "$base" ]; then
              echo "Configuring Android Studio VM options..."
              for dir in "$base"/AndroidStudio*; do
                if [ -d "$dir" ]; then
                  echo "  → Writing studio.vmoptions to $dir"
                  mkdir -p "$dir"
                  printf "%s\n" "$vmopts" > "$dir/studio.vmoptions"
                fi
              done
              echo "✓ Android Studio VM options configured successfully"
            else
              echo "⚠ Android Studio directory not found: $base"
              echo "  VM options will be applied when Android Studio is first launched"
            fi
    '';
  };
}
