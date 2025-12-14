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
        # Multiple pagers are supported; you can cycle through them with the `|` key
        pagers = [
          # delta view with hyperlinks
          {
            pager = "delta --paging=never --features catppuccin-mocha --navigate --line-numbers --whitespace-error-style \"22 reverse\" --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
          }
          # delta side-by-side view with hyperlinks
          {
            pager = "delta --paging=never --side-by-side --features catppuccin-mocha --navigate --line-numbers --whitespace-error-style \"22 reverse\" --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
          }

          # Example: diff-so-fancy
          # {
          #   pager = "diff-so-fancy";
          # }

          # Example: ydiff (side-by-side)
          # {
          #   pager = "ydiff -p cat -s --wrap --width={{columnWidth}}";
          #   colorArg = "never";
          # }

          # Example: external diff command (e.g., difftastic)
          # {
          #   externalDiffCommand = "difft --color=always";
          #   # Note: colorArg and pager are not used with externalDiffCommand
          # }

          # Example: use git's diff.external config
          # {
          #   useExternalDiffGitConfig = true;
          # }
        ];

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
