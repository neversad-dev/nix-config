# Fuzzy finder (Ctrl-T / history) with fd-backed file search
{...}: {
  programs.fzf = {
    enable = true;

    tmux.enableShellIntegration = true;

    defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
    fileWidgetCommand = "fd --hidden --strip-cwd-prefix --exclude .git"; # CTRL-T
  };
}
