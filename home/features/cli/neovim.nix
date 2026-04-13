{
  config,
  lib,
  nvf-config,
  pkgs,
  ...
}: with lib; let
  cfg = config.features.cli.neovim;
in {
  options.features.cli.neovim.enable = mkEnableOption "Neovim from nvf-config";

  config = mkIf cfg.enable {
    home.packages = [
      nvf-config.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
