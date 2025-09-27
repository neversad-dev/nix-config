{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vim
    git
    just
    jq
  ];
}
