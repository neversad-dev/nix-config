{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    git
    just
    jq
  ];
  environment.variables.EDITOR = "nvim";
}
