# Zed editor (opt-in)
{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
with lib; let
  cfg = config.features.desktop.zed;
in {
  options.features.desktop.zed.enable = mkEnableOption "Zed editor";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      alejandra
      prettier
      shfmt
      ruff
    ];

    programs.zed-editor = {
      enable = true;
      package = pkgs-unstable.zed-editor;

      extensions = [
        "catppuccin"
        "catppuccin-blur"
        "nix"
        "just"
        "basher"
        "xml"
        "git-firefly"
      ];

      userKeymaps = [
        {
          context = "Workspace";
          bindings = {
            ctrl-shift-t = "workspace::NewTerminal";
          };
        }
      ];

      userSettings = {
        # outline_panel = {
        #   dock = "right";
        # };
        # project_panel = {
        #   dock = "right";
        # };

        autosave = {
          after_delay = {
            milliseconds = 1000;
          };
        };
        tab_bar = {
          show = true;
          show_nav_history_buttons = false;
        };

        wrap_guides = [
          80
          120
        ];
        terminal = {
          font_family = config.myFonts.main;
        };
        soft_wrap = "editor_width";
        format_on_save = "on";
        features = {
          copilot = true;
        };
        languages = {
          Nix = {
            formatter = {
              external = {
                command = "alejandra";
                arguments = ["--quiet" "-"];
              };
            };
            format_on_save = "on";
          };
          Markdown = {
            formatter = "prettier";
            format_on_save = "on";
          };
          Shell = {
            formatter = {
              external = {
                command = "shfmt";
                arguments = ["-i" "2" "-"];
              };
            };
            format_on_save = "on";
          };

          Python = {
            formatter = {
              external = {
                command = "ruff";
                arguments = ["format" "-"];
              };
            };
            format_on_save = "on";
          };
        };
        telemetry = {
          metrics = false;
        };
        vim_mode = true;
        relative_line_numbers = "enabled";
        ui_font_size = 12;
        buffer_font_size = 14;

        buffer_font_family = config.myFonts.main;
      };
    };
  };
}
