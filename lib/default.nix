{lib, ...}: {
  relativeToRoot = lib.path.append ../.;

  scanPaths = path:
    builtins.map
    (f: (path + "/${f}"))
    (builtins.attrNames
      (lib.attrsets.filterAttrs
        (
          path: _type:
            (
              (_type == "directory") # include directories
              && !lib.strings.hasPrefix "_" path # ignore directories starting with _
            )
            || (
              (path != "default.nix") # ignore default.nix
              && (lib.strings.hasSuffix ".nix" path) # include .nix files
            )
        )
        (builtins.readDir path)));

  # Creates an editable config file with backup functionality
  # Usage: mkEditableConfig {
  #   name = "myapp";
  #   configPath = "$HOME/.config/myapp/config";
  #   content = "config content here";
  #   pkgs = pkgs; # recommended for delta diffs and jq formatting
  #   isJson = false; # optional, formats with jq if true
  # }
  mkEditableConfig = {
    name,
    configPath,
    content,
    pkgs ? null,
    isJson ? false,
  }: let
    configDir = builtins.dirOf configPath;
    configFile = builtins.baseNameOf configPath;
    backupFile = "${configDir}/${configFile}.home-manager.backup";

    # Use delta if available, fallback to diff
    diffCommand =
      if pkgs != null
      then "${pkgs.delta}/bin/delta --file-style=omit --hunk-header-style=omit"
      else "diff -u";
  in ''
        CONFIG_DIR="${configDir}"
        CONFIG_FILE="${configPath}"
        BACKUP_FILE="${backupFile}"

        # Create directory if it doesn't exist
        mkdir -p "$CONFIG_DIR"

        # Create new config content in a temp file (safely, without shell interpretation)
        TEMP_FILE=$(mktemp)
        if ${
      if isJson && pkgs != null
      then "true"
      else "false"
    }; then
          # For JSON: use jq to format
          echo '${content}' | ${
      if pkgs != null
      then "${pkgs.jq}/bin/jq '.'"
      else "cat"
    } > "$TEMP_FILE"
        else
          # For plain text: write content directly to avoid shell interpretation
          cat > "$TEMP_FILE" << 'NIXEOF'
    ${content}NIXEOF
        fi

        # If config exists and is different from new content, create backup and show diff
        if [ -f "$CONFIG_FILE" ]; then
          if ! cmp -s "$CONFIG_FILE" "$TEMP_FILE"; then
            cp "$CONFIG_FILE" "$BACKUP_FILE"
            echo "" >&2
            printf "📁 \033[1;36m%s\033[0m config backed up to %s\n" "${name}" "$BACKUP_FILE" >&2
            printf "🔄 Overwriting manual changes in \033[1;33m%s\033[0m config (%s):\n" "${name}" "$CONFIG_FILE" >&2
            ${diffCommand} "$CONFIG_FILE" "$TEMP_FILE" >&2 || true
            echo "" >&2
          fi
        fi

        # Always overwrite with new config
        cp "$TEMP_FILE" "$CONFIG_FILE"
        rm "$TEMP_FILE"

        # Make sure it's writable
        chmod 644 "$CONFIG_FILE"

  '';
}
