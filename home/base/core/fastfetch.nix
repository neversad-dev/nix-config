# System info in the terminal (neofetch-style)
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.cli.fastfetch;
in {
  options.features.cli.fastfetch = {
    enable = lib.mkEnableOption "fastfetch greeting";
    logo = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Built-in fastfetch logo name (e.g. 'android', 'nixos', 'macos').";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fastfetch
    ];

    home.file.".config/fastfetch/config.jsonc".text =
      builtins.toJSON (
        {
          modules = [
            "title"
            "separator"
            "os"
            {
              type = "host";
              format = "{/2}{-}{/}{2}{?3} {3}{?}";
            }
            "kernel"
            "uptime"
            {
              type = "battery";
              format = "{/4}{-}{/}{4}{?5} [{5}]{?}";
            }
            "break"
            "packages"
            "shell"
            "display"
            "terminal"
            "break"
            "cpu"
            {
              type = "gpu";
              key = "GPU";
            }
            "memory"
            "break"
            "colors"
          ];
        }
        // lib.optionalAttrs (cfg.logo != null) {
          logo = cfg.logo;
        }
      );

    programs.zsh = {
      initContent = ''
        fastfetch
      '';
    };

    programs.bash = {
      initExtra = ''
        fastfetch
      '';
    };
  };
}
