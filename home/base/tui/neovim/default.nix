# Neovim via nvf, exposed as a regular Home Manager module.
{
  config,
  lib,
  mylib,
  nvf,
  ...
}: {
  imports = [nvf.homeManagerModules.default];

  options.features.cli.neovim.enable = lib.mkEnableOption "Neovim (nvf, configured in home/base/tui/neovim)";

  config = lib.mkIf config.features.cli.neovim.enable {
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
