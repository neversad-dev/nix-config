{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    neovim
    git
    just
    jq
    home-manager
  ];
}
