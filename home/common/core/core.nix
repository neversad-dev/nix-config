{pkgs, ...}: {
  home.packages = with pkgs; [
    # nix related
    #
    # It provides the command `nom`, which works just like `nix`
    # but with more detailed log output.
    nix-output-monitor
    nix-melt # A TUI flake.lock viewer
    nix-tree # A TUI to visualize the dependency graph of a nix derivation

    # misc
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
