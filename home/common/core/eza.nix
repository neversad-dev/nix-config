{...}: {
  # A modern replacement for ‘ls’
  # useful in bash/zsh prompt, not in nushell.
  programs.eza = {
    enable = true;
    git = true;
    extraOptions = [
      "--icons=always"
      "--color=always"
      "--long"
      "--no-filesize"
      "--no-time"
      "--no-user"
      "--no-permissions"
      "--group-directories-first"
      "--header"
    ];
  };
}
