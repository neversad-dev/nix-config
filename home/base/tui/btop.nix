# TUI system monitor: CPU, memory, disks, network, and processes (successor to bpytop)
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.btop;
in {
  options.features.cli.btop.enable = mkEnableOption "btop system monitor";

  config = mkIf cfg.enable {
    programs.btop = {
      enable = true;
      settings = {
        vim_keys = true;
        base_10_sizes = true;
        proc_sorting = "cpu lazy";
        theme_background = false; # make btop transparent
      };
    };
  };
}
