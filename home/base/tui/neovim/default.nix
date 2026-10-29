# Neovim via nvf, exposed as a regular Home Manager module.
{
  config,
  lib,
  mylib,
  nvf,
  ...
}: let
  cfg = config.features.cli.neovim;
  # Sibling nvf modules gated by HM feature flags. nvf modules can't see HM
  # `features`, so gating happens here at import time.
  gated = {
    "languages.nix" = cfg.languages.enable;
    "debugger.nix" = cfg.debugger.enable;
  };
  enabled = p: gated.${baseNameOf p} or true;
in {
  imports = [nvf.homeManagerModules.default];

  options.features.cli.neovim = {
    enable = lib.mkEnableOption "Neovim (nvf, configured in home/base/tui/neovim)";
    languages.enable =
      lib.mkEnableOption "LSP, formatters and language support (languages.nix)"
      // {default = true;};
    debugger.enable =
      lib.mkEnableOption "nvim-dap debugger (debugger.nix)"
      // {default = true;};
  };

  config = lib.mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      defaultEditor = true; # sets EDITOR/VISUAL to nvim
      settings = {
        # nvf modules in this directory; default.nix (this file) is skipped.
        imports = builtins.filter enabled (mylib.scanPaths ./.);
      };
    };

    home.sessionVariables.VISUAL = "nvim";
  };
}
