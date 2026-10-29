# Catppuccin theme for supported terminal and editor integrations.
# Global switch (vars/features.nix): gates this module and every inline
# catppuccin theme string so all hosts switch themes together.
{
  config,
  lib,
  catppuccin,
  isHm24 ? false, # set by hosts using HM 24.05 (nix-on-droid)
  ...
}:
with lib; let
  # `lib.modules ? importApply` used to be a reliable HM-version marker,
  # but with nixpkgs-unstable packages `lib` is the unstable lib even on
  # HM 24.05 — so the android host sets isHm24 explicitly instead.
  hasModule = !isHm24 && lib.modules ? importApply;
in
  if hasModule
  then {
    imports = [
      catppuccin.homeModules.catppuccin
    ];

    config = mkIf config.features.theme.catppuccin.enable {
      catppuccin = {
        enable = true; # global toggle; ports default to this
        cache.enable = true;
        autoEnable = true;
        flavor = "mocha";
        accent = "lavender"; # "blue", "flamingo", "green", "lavender", "maroon", "mauve", "peach", "pink", "red", "rosewater", "sapphire", "sky", "teal", "yellow"
        cursors.enable = false; # not supported for darwin
        cursors.accent = "mauve"; # "blue", "flamingo", "green", "lavender", "maroon", "mauve", "peach", "pink", "red", "rosewater", "sapphire", "sky", "teal", "yellow"
        vscode.profiles.default.enable = false; # disable automatic vscode extension management to avoid conflicts
      };
    };
  }
  else {
    # nixpkgs-24.05 doesn't have lib.modules.importApply; skip catppuccin entirely.
  }
