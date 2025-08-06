{pkgs, ...}: let
  commonSettings = (import ./common.nix {inherit pkgs;}).commonSettings;
  settingsJson = builtins.toJSON commonSettings;
in {
  # Copy settings to create an editable file (not a symlink)
  home.activation.copyCursorSettings = ''
    SETTINGS_DIR="$HOME/Library/Application Support/Cursor/User"
    SETTINGS_FILE="$SETTINGS_DIR/settings.json"

    # Create directory if it doesn't exist
    mkdir -p "$SETTINGS_DIR"

    # Format JSON with jq and copy settings as a real file (overwrites existing)
    echo '${settingsJson}' | ${pkgs.jq}/bin/jq '.' > "$SETTINGS_FILE"

    # Make sure it's writable
    chmod 644 "$SETTINGS_FILE"

    echo "Cursor settings copied to $SETTINGS_FILE (editable, formatted)"
  '';
}
