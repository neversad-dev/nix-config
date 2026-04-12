{...}: {
  programs.kitty = {
    enable = true;

    # Catppuccin theme - using themeFile instead of deprecated theme option
    themeFile = "Catppuccin-Mocha";

    # Font configuration
    font = {
      name = "JetBrains Mono";
      size = 14;
    };

    # Basic settings
    settings = {
      # Window settings
      window_padding_width = 8;
      hide_window_decorations = "titlebar-only";

      # Tab settings
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";

      # Cursor settings
      cursor_shape = "beam";
      cursor_blink_interval = 0.5;

      # Scrollback
      scrollback_lines = 10000;

      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;

      # Shell integration
      shell_integration = "enabled";

      # Misc
      enable_audio_bell = false;
      visual_bell_duration = 0.0;
      confirm_os_window_close = 0;
    };
  };
}
