# Fuzzy finder (Ctrl-T / history) with fd-backed file search
{pkgs-unstable, ...}: {
  programs.fzf = {
    enable = true;
    package = pkgs-unstable.fzf;

    tmux.enableShellIntegration = true;

    defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
    fileWidgetCommand = "fd --hidden --strip-cwd-prefix --exclude .git"; # CTRL-T
  };
}
