# tealdeer: fast tldr client (condensed command examples) (opt-in)
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.tldr;
in {
  options.features.cli.tldr.enable = mkEnableOption "tealdeer (tldr) client";

  config = mkIf cfg.enable {
    programs.tealdeer = {
      enable = true;
      enableAutoUpdates = true;
      settings = {
        display = {
          compact = false;
          use_pager = true;
          show_title = true;
        };
        updates = {
          auto_update = true;
          auto_update_interval_hours = 168; # 1 week
        };
      };
    };
  };
}
