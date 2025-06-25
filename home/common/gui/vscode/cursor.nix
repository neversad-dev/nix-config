{
  lib,
  config,
  pkgs,
  ...
}: let
  commonSettings = (import ./common.nix {inherit pkgs;}).commonSettings;
  # Convert to JSON and format with jq
  formatJSON = settings:
    pkgs.runCommand "formatted-settings.json" {} ''
      echo '${builtins.toJSON settings}' | ${pkgs.jq}/bin/jq '.' > $out
    '';
in
  lib.mkIf config.personal.enable {
    # Create the Cursor settings directory and configuration
    home.file."Library/Application Support/Cursor/User/settings.json" = {
      text = builtins.readFile (formatJSON commonSettings);
    };
  }
