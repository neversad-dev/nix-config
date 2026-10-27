# Fuzzy finder (Ctrl-T / history) with fd-backed file search
{...}: {
  programs.fzf = {
    enable = true;

    defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
    fileWidget.command = "fd --hidden --strip-cwd-prefix --exclude .git"; # CTRL-T
    historyWidget.command = ""; # disable fzf Ctrl-R, atuin owns it
  };
}
