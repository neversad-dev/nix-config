# TUI system monitor: CPU, memory, disks, network, and processes (successor to bpytop)
{...}: {
  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
      base_10_sizes = true;
      proc_sorting = "cpu lazy";
      theme_background = false; # make btop transparent
    };
  };
}
