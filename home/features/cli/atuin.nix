# Atuin: searchable shell history (SQLite); optional encrypted sync
{...}: {
  programs = {
    atuin = {
      enable = true;
      enableZshIntegration = true;
      daemon.enable = true;
      # flags = [ "--disable-up-arrow" "--disable-ctrl-r" ];
      forceOverwriteSettings = true;
      settings = {
        enter_accept = true;
      };
    };
  };
}
