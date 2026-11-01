# Atuin: searchable shell history (SQLite); optional encrypted sync
{
  config,
  lib,
  ...
}: {
  options.features.cli.atuin.enable = lib.mkEnableOption "Atuin shell history";

  config = lib.mkIf config.features.cli.atuin.enable {
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
  };
}
