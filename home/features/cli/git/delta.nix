# Modern diff viewer for Git
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.git;
in {
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      delta
    ];

    programs.git = {
      includes = [
        {
          path = let
            catppuccin-delta = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "delta";
              rev = "011516f5d14f66b771b3e716f29c77231e008c74";
              sha256 = "sha256-04po0A7bVMsmYdJcKL6oL39RlMLij1lRKvWl5AUXJ7Q=";
            };
          in "${catppuccin-delta}/catppuccin.gitconfig";
        }
      ];

      settings = {
        delta = {
          enable = true;
          side-by-side = false;
          navigate = true;
          features = "catppuccin-mocha";
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
