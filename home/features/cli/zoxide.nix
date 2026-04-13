# Smarter cd: jump to frequent and recent directories (z/autojump-style)
{...}: {
  programs.zoxide = {
    enable = true;
    options = [
      "--cmd cd"
    ];
  };
}
