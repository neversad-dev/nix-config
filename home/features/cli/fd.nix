{...}: {
  # search for files by name, faster than find
  programs.fd = {
    enable = true;
    hidden = true;
    ignores = [
      ".git/"
    ];
  };
}
