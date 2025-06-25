{pkgs, ...}: {
  home.packages = with pkgs; [
    pay-respects
  ];

  programs.zsh.initContent = ''
    eval "$(pay-respects zsh --alias)"
  '';
}
