{...}: {
  programs.lazygit = {
    enable = true;
    settings = {
      # Config relating to the Lazygit UI
      gui = {
        # Format used when displaying time e.g. commit time.
        # Uses Go's time format syntax: https://pkg.go.dev/time#Time.Format
        timeFormat = "2006-01-02";

        # Format used when displaying time if the time is less than 24 hours ago.
        # Uses Go's time format syntax: https://pkg.go.dev/time#Time.Format
        shortTimeFormat = "15:04";

        theme = {
        };
        # Nerd fonts version to use.
        # One of: '2' | '3' | empty string (default)
        # If empty, do not show icons.
        nerdFontsVersion = "3";

        # Whether to split the main window when viewing file changes.
        # One of: 'auto' | 'always'
        # If 'auto', only split the main window when a file has both staged and unstaged changes
        splitDiff = "auto";

        # How things are filtered when typing '/'.
        # One of 'substring' (default) | 'fuzzy'
        filterMode = "fuzzy";
      };

      # Config relating to git
      git = {
        # See https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Pagers.md
        paging = {
          # e.g.
          # diff-so-fancy
          # delta --dark --paging=never
          # ydiff -p cat -s --wrap --width={{columnWidth}}
          # pager = "delta";  # TODO

          # e.g. 'difft --color=always'
          #externalDiffCommand = "--color=always";
        };

        # If true, parse emoji strings in commit messages e.g. render :rocket: as 🚀
        # (This should really be under 'gui', not 'git')
        parseEmoji = true;
      };
    };
  };

  home.shellAliases = {
    lg = "lazygit";
  };
}
