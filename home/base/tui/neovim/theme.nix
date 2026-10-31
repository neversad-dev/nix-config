{pkgs, ...}: {
  vim = {
    theme = {
      enable = true;
      name = "catppuccin";
      style = "mocha";
      transparent = true;
    };

    # Keep the smart cursorline (only shows in the active split)
    autocmds = [
      {
        event = ["WinEnter" "BufEnter" "FocusGained"];
        command = "setlocal cursorline";
      }
      {
        event = ["WinLeave" "BufLeave" "FocusLost"];
        command = "setlocal nocursorline";
      }
    ];

    # Add tint.nvim to dim the text/content instead of the background
    extraPlugins = {
      tint = {
        package = pkgs.vimPlugins.tint-nvim;
        setup = ''
          require("tint").setup({
            tint = -45,                     -- How much to darken the text (negative = darker)
            saturation = 0.5,               -- Desaturate the syntax colors by 50%
            tint_background_colors = false, -- THE FIX: Do not touch backgrounds, keeping them transparent
            highlight_ignore_patterns = { "WinSeparator", "Status.*" },
          })
        '';
      };
    };
  };
}
