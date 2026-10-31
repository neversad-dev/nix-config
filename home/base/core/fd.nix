# Fast filename search (user-friendly find alternative)
{...}: {
  programs.fd = {
    enable = true;
    hidden = true;
    ignores = [
      ".git/"
    ];
  };
}
