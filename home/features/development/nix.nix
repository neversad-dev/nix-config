# Nix tooling: nh, nom, flake.lock/derivation TUIs, nixd, alejandra; nixPath for nixd (opt-in)
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.features.development.nix;
in {
  options.features.development.nix.enable = mkEnableOption "Nix dev stack (nh, nom, nix-melt, nix-tree, nixd, alejandra; nixPath for nixd)";

  config = mkIf cfg.enable {
    home.sessionVariables = {
      # nix-community/nh#305
      NH_NO_CHECKS = "1";
    };

    home.packages = with pkgs; [
      just
      # `nom` — like `nix` with richer build logs
      nix-output-monitor
      nix-melt # TUI flake.lock viewer
      nix-tree # TUI dependency graph for a derivation

      nixd # lsp for nix
      alejandra # formatter for nix
    ];

    programs.nh = {
      enable = true;
      flake = ".";
    };

    nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"]; # for nixd
  };
}
