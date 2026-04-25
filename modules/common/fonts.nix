{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  enabled = config.features.desktop.fonts.enable;
in {
  config.fonts.packages = with pkgs;
    lib.optionals enabled [
      # icon fonts
      material-design-icons
      font-awesome

      # nerdfonts
      # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/pkgs/data/fonts/nerdfonts/shas.nix
      nerd-fonts.symbols-only # symbols icon only
      nerd-fonts.fira-code
      nerd-fonts.iosevka
      nerd-fonts.meslo-lg
      nerd-fonts.hack
    ];
}
