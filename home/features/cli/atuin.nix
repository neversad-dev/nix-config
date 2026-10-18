# Atuin: searchable shell history (SQLite); optional encrypted sync
{pkgs, ...}: {
  programs = {
    atuin = {
      enable = true;
      enableZshIntegration = true;
      daemon.enable = true;
      package = pkgs.atuin;
      # flags = [ "--disable-up-arrow" "--disable-ctrl-r" ];
      forceOverwriteSettings = true;
      settings = {
        enter_accept = true;
      };
    };
  };
}
