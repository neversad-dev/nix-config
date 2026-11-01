{
  mylib,
  pkgs,
  ...
}: {
  imports = mylib.scanPaths ./.;
  programs.bat.enable = true;
  home.packages = with pkgs; [
    coreutils
    htop
    jq
    yq
    ripgrep
    zip
    python3
  ];
}
