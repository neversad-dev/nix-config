{...}: {
  programs = {
    # terminal file manager
    yazi = {
      enable = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_dir_first = true;
        };
      };
    };
  };
}
