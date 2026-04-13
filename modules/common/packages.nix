{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    jq
    git
    neovim
  ];
}
