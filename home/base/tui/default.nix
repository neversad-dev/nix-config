{
  mylib,
  pkgs,
  ...
}: {
  imports = mylib.scanPaths ./.;
  home.packages = with pkgs; [httpie procs cowsay cmatrix];
}
