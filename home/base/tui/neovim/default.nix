# Neovim via nvf, exposed as a regular Home Manager module.
{
  config,
  lib,
  mylib,
  nvf,
  ...
}: let
  cfg = config.features.cli.neovim;
in {
  imports = [nvf.homeManagerModules.default];

  options.features.cli.neovim.enable = lib.mkEnableOption "Neovim (nvf, configured in home/base/tui/neovim)";

  config = lib.mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      defaultEditor = true; # sets EDITOR/VISUAL to nvim
      settings = {
        # nvf modules in this directory; default.nix (this file) is skipped.
        imports = mylib.scanPaths ./.;
      };
    };

    home.sessionVariables.VISUAL = "nvim";
  };
}
