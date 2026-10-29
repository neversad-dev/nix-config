{...}: {
  vim = {
    filetree.neo-tree = {
      enable = true;
      setupOpts = {
        enable_cursor_hijack = true;
      };
    };

    keymaps = [
      {
        key = "<C-n>";
        mode = "n";
        silent = true;
        action = ":Neotree filesystem reveal left<CR>";
      }
    ];
  };
}
