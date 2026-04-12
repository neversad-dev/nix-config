{...}: {
  # very fast version of tldr in Rust
  programs.tealdeer = {
    enable = true;
    enableAutoUpdates = true;
    settings = {
      display = {
        compact = false;
        use_pager = true;
        show_title = true;
      };
      updates = {
        auto_update = true;
        auto_update_interval_hours = 168; # 1 week
      };
    };
  };
}
