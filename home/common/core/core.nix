{pkgs, ...}: {
  home.packages = with pkgs; [
    # Misc
    tlrc
    cowsay
    cmatrix
    yq
    python3
  ];

  programs = {
    # a cat(1) clone with syntax highlighting and Git integration.
    bat = {
      enable = true;
    };
  };
}
