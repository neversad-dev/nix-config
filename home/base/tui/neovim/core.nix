{...}: {
  # all options: https://notashelf.github.io/nvf/options.html
  vim = {
    viAlias = true;
    vimAlias = true;

    globals = {
      mapleader = " ";
      localleader = "\\";
    };

    spellcheck = {
      enable = true;
      programmingWordlist.enable = true;
    };

    autopairs.nvim-autopairs.enable = true;
  };
}
