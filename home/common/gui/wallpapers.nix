{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.wallpapers;
in {
  options.wallpapers = {
    enable = lib.mkEnableOption "wallpapers management";

    autoDownload = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to automatically download wallpapers on activation";
    };

    url = lib.mkOption {
      type = lib.types.str;
      default = "https://github.com/neversad-dev/wallpapers.git";
      description = "URL of wallpapers repository";
    };
  };

  config = lib.mkIf cfg.enable {
    # Add wallpapers management script
    home.packages = [
      (pkgs.writeShellScriptBin "fetch-wallpapers" ''
        WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
        echo "Downloading wallpapers from ${cfg.url}..."

        if [ -d "$WALLPAPERS_DIR" ]; then
          echo "Wallpapers directory exists, updating..."
          cd "$WALLPAPERS_DIR" && git pull
        else
          echo "Cloning wallpapers repository..."
          git clone "${cfg.url}" "$WALLPAPERS_DIR"
        fi

        echo "Wallpapers available at $WALLPAPERS_DIR"
      '')
    ];

    # Optionally auto-download on activation
    home.activation.downloadWallpapers = lib.mkIf cfg.autoDownload (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgs.bash}/bin/bash -c "fetch-wallpapers"
      ''
    );
  };
}
