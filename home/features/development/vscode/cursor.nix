{
  pkgs,
  mylib,
  lib,
  config,
  ...
}: let
  commonSettings = (import ./common.nix {inherit pkgs;}).commonSettings;
  cursorSettings =
    commonSettings
    // {
      "cursor.composer.usageSummaryDisplay" = "always";
    };
  settingsJson = builtins.toJSON cursorSettings;

  # ~/.cursor/mcp.json — same path on macOS and Linux
  mcpConfig = {
    mcpServers = {
      "Mobile MCP" = {
        command = "npx";
        args = [
          "-y"
          "@mobilenext/mobile-mcp@latest"
        ];
        env = {};
      };
    };
  };
  mcpJson = builtins.toJSON mcpConfig;

  # ~/.cursor/permissions.json — same path on macOS and Linux
  permissionsConfig = {
    terminalAllowlist = ["./gradlew"];
  };
  permissionsJson = builtins.toJSON permissionsConfig;
in {
  config = lib.mkIf config.features.development.cursor.enable {
    # Copy settings to create an editable file (not a symlink)
    home.activation.copyCursorSettings = mylib.mkEditableConfig {
      name = "Cursor";
      configPath = "$HOME/Library/Application Support/Cursor/User/settings.json";
      content = settingsJson;
      pkgs = pkgs;
      isJson = true;
    };

    home.activation.copyCursorMcp = mylib.mkEditableConfig {
      name = "Cursor MCP";
      configPath = "$HOME/.cursor/mcp.json";
      content = mcpJson;
      pkgs = pkgs;
      isJson = true;
    };

    home.activation.copyCursorPermissions = mylib.mkEditableConfig {
      name = "Cursor permissions";
      configPath = "$HOME/.cursor/permissions.json";
      content = permissionsJson;
      pkgs = pkgs;
      isJson = true;
    };
  };
}
