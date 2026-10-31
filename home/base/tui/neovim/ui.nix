{...}: {
  vim = {
    statusline.lualine.integrations.breadcrumbs = {
      nvim-navic.enable = true;
      navbuddy.enable = false;
    };

    visuals = {
      nvim-scrollbar.enable = false; # Disables the scrollbar in the editor
      nvim-web-devicons.enable = true; # Adds file type icons to various UI elements
      # Provides smooth scrolling animations
      cinnamon-nvim = {
        enable = true;

        setupOpts = {
          keymaps = {
            basic = true;
            # extra = true;
          };
        };
      };
      highlight-undo.enable = true; # Highlights text changes after undo/redo operations
      indent-blankline.enable = true; # Shows indentation guides and blank line markers
    };

    options = {
      cursorline = true;
    };
    treesitter.context.enable = true; # keep the current function/class header visible at the top as you scroll

    ui = {
      borders.enable = true;
      noice = {
        enable = true;

        setupOpts.presets = {
          command_palette = true;
          long_message_to_split = true;
        };
      };
      # noice.enable = true;
      colorizer.enable = true;
      modes-nvim.enable = false;
      illuminate.enable = true;
      fastaction.enable = true;
    };
  };
}
