{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    neovim
    git
    just
    jq
  ];
  environment.variables.EDITOR = "nvim";
}
