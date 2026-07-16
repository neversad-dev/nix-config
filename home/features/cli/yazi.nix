# Terminal file manager (Yazi)
{...}: {
  programs = {
    yazi = {
      enable = true;
      shellWrapperName = "yy";
      settings = {
        mgr = {
          show_hidden = true;
          sort_dir_first = true;
        };
      };
    };
  };
}
