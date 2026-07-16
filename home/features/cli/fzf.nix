# Fuzzy finder (Ctrl-T / history) with fd-backed file search
{...}: {
  programs.fzf = {
    enable = true;

    tmux.enableShellIntegration = true;
    historyWidget.command = "";

    defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
    fileWidget.command = "fd --hidden --strip-cwd-prefix --exclude .git"; # CTRL-T
  };
}
