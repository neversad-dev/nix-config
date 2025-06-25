{pkgs, ...}: {
  home.packages = with pkgs; [
    neovim
    git
    just
    jq

    telegram-desktop
    zed-editor
  ];
}
