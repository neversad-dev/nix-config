# Modern ls with icons and git hints (bash/zsh; not wired for nushell here)
{...}: {
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
