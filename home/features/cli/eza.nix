# Modern ls with icons and git hints (bash/zsh; not wired for nushell here)
{...}: {
  programs.eza = {
    enable = true;
    git = true;
    # Keep defaults compatible with `ls` expectations:
    # - show permissions/user/group when `-l` is requested
    # - don't force long format for plain `ls`
    extraOptions = [
      "--icons=always"
      "--color=always"
      "--group-directories-first"
    ];
  };

  # Make `ls` resolve to eza consistently, while preserving `ls -l` output
  # including permissions and owner/group.
  home.shellAliases = {
    ls = "eza -1";
    ll = "eza -l";
    la = "eza -la";
  };
}
