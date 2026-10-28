# Neovim from nvf-config flake (opt-in)
{
  config,
  lib,
  pkgs,
  nvf-config ? null,
  ...
}:
with lib; let
  cfg = config.features.cli.neovim;
in {
  options.features.cli.neovim.enable = mkEnableOption "Neovim from nvf-config";

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = nvf-config != null;
        message = "features.cli.neovim.enable requires the nvf-config flake input in extraSpecialArgs.";
      }
    ];
    home.packages =
      lib.optional (nvf-config != null)
      nvf-config.packages.${pkgs.stdenv.hostPlatform.system}.default;

    # Override default vim editor when neovim is explicitly enabled
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
