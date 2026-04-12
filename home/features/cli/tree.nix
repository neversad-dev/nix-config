{pkgs, ...}: {
  home.packages = with pkgs; [
    tree
  ];

  programs.zsh.shellAliases = {
    tre = "tree -C";
    tred = "tree -C -d";
    tres = "tree -C -s -h --du";
  };
}
