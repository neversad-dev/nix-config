# Atuin: searchable shell history (SQLite); optional encrypted sync
{pkgs-unstable, ...}: {
  programs = {
    atuin = {
      enable = true;
      package = pkgs-unstable.atuin;
      settings = {
        enter_accept = true;
      };
    };
  };
}
