{
  mylib,
  pkgs,
  ...
}: {
  imports =
    mylib.scanPaths ./.;

  programs.bat = {enable = true;};

  home.packages = with pkgs; [
    # nix related
    #
    # It provides the command `nom`, which works just like `nix`
    # but with more detailed log output.
    nix-output-monitor
    nix-melt # A TUI flake.lock viewer
    nix-tree # A TUI to visualize the dependency graph of a nix derivation

    coreutils
    fd
    htop
    httpie
    jq
    yq
    procs
    ripgrep
    zip
    cowsay
    cmatrix
    python3
  ];
}
