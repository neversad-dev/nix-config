# CLI feature imports plus shared command-line packages
{
  mylib,
  pkgs,
  ...
}: {
  imports =
    mylib.scanPaths ./.;

  programs.bat = {enable = true;};

  home.packages = with pkgs; [
    coreutils # GNU basics: ls, cp, mkdir, and related file utilities
    htop # Interactive process and resource monitor
    httpie # Human-friendly CLI for HTTP requests (curl-like)
    jq # Command-line JSON query/filter
    yq # Command-line YAML (and related) processor
    procs # Modern ps replacement with colors and search
    ripgrep # Fast recursive grep (rg)
    zip # Create and extract .zip archives
    cowsay # Prints messages in an ASCII cow (or other figures)
    cmatrix # Terminal “Matrix” digital rain screensaver
    python3 # Python interpreter and stdlib
  ];
}
