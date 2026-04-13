# Atuin: searchable shell history (SQLite); optional encrypted sync
{...}: {
  programs = {
    atuin = {
      enable = true;
      settings = {
        enter_accept = true;
      };
    };
  };
}
