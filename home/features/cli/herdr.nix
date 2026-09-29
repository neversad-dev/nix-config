{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  xdg.dataFile."herdr/plugins/aimdevlee/herdr-nvim-nav".source = pkgs.herdr-nvim-nav;

  programs.herdr = {
    enable = true;
    package = pkgs-unstable.herdr;
    settings = {
      onboarding = false;
      theme = {
        name = "catppuccin";
      };
      ui = {
        sound = {
          enabled = false;
        };
        toast = {
          delivery = "system";
        };
        status_indicators = "symbols";
      };
      keys = {
        # Unbind default navigation so the plugin can intercept the keys
        focus_pane_left = "";
        focus_pane_down = "";
        focus_pane_up = "";
        focus_pane_right = "";

        command = [
          {
            key = "ctrl+h";
            type = "plugin_action";
            command = "herdr-nvim-nav.left";
          }
          {
            key = "ctrl+j";
            type = "plugin_action";
            command = "herdr-nvim-nav.down";
          }
          {
            key = "ctrl+k";
            type = "plugin_action";
            command = "herdr-nvim-nav.up";
          }
          {
            key = "ctrl+l";
            type = "plugin_action";
            command = "herdr-nvim-nav.right";
          }
        ];
      };
    };
  };

  # Declaratively link the plugin during Home Manager activation
  home.activation.linkHerdrNavPlugin = lib.hm.dag.entryAfter ["linkGeneration"] ''
    # Reference the exact Herdr binary and XDG data path dynamically
    HERDR_BIN="${config.programs.herdr.package}/bin/herdr"
    PLUGIN_PATH="${config.xdg.dataHome}/herdr/plugins/aimdevlee/herdr-nvim-nav"

    if [ -x "$HERDR_BIN" ] && [ -d "$PLUGIN_PATH" ]; then
      $DRY_RUN_CMD "$HERDR_BIN" plugin link "$PLUGIN_PATH"
    fi
  '';
}
