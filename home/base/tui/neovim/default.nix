# Neovim via nvf, exposed as a regular Home Manager module.
{
  config,
  lib,
  mylib,
  nvf,
  osConfig,
  pkgs,
  ...
}: {
  imports = [nvf.homeManagerModules.default];

  options.features.cli.neovim.enable =
    lib.mkEnableOption "Neovim (nvf, configured in home/base/tui/neovim)";

  config = lib.mkIf config.features.cli.neovim.enable {
    programs.nvf = {
      enable = true;
      defaultEditor = true; # sets EDITOR/VISUAL to nvim
      settings = {lib, ...}: {
        # nvf modules in this directory; default.nix (this file) is skipped.
        imports = mylib.scanPaths ./.;

        # Propagate the outer catppuccin flag into nvf: theme.nix enables the
        # Catppuccin theme unconditionally (nvf settings modules don't see HM's
        # `config`), so force-disable it here when the theme feature is off.
        # The standalone Neovim package keeps its unconditional themed config.
        vim.theme.enable = lib.mkIf (!config.features.theme.catppuccin.enable) (lib.mkForce false);

        # Android has no system-level secrets (and uses an older plugin set).
        vim.assistant.codecompanion-nvim = lib.mkIf (config.features.ai.enable && pkgs.stdenv.hostPlatform.isDarwin) {
          enable = true;
          setupOpts.adapters = lib.mkLuaInline ''
            {
              http = {
                openrouter = function()
                  return require("codecompanion.adapters").extend("openrouter", {
                    env = {
                      api_key = ${builtins.toJSON "cmd:${lib.getExe' pkgs.coreutils "cat"} ${lib.escapeShellArg osConfig.age.secrets."openrouter-codecompanion".path}"},
                    },
                    schema = {
                      model = { default = "openrouter/auto" },
                    },
                  })
                end,
              },
            }
          '';
        };
      };
    };

    home.sessionVariables.VISUAL = "nvim";
  };
}
