# Modern diff viewer for Git
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.git;
  # Follow the global theme flag (vars/features.nix).
  theme = config.features.theme.catppuccin.enable;
in {
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      delta
    ];

    programs.git = {
      includes = lib.optionals theme [
        {
          path = let
            catppuccin-delta = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "delta";
              rev = "011516f5d14f66b771b3e716f29c77231e008c74";
              sha256 = "sha256-lztkxX9O41YossvRzpR7tqxMhDNT1Efy2JvkCwtsiXQ=";
            };
          in "${catppuccin-delta}/catppuccin.gitconfig";
        }
      ];

      settings = {
        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
        delta = {
          enable = true;
          side-by-side = false;
          navigate = true;
          features = mkIf theme "catppuccin-mocha";
          line-numbers = true;
          whitespace-error-style = "22 reverse";
          hyperlinks = true;
          hyperlinks-file-link-format = "file://{path}:{line}";
          hyperlinks-file = "file://{path}";
        };
      };
    };
  };
}
