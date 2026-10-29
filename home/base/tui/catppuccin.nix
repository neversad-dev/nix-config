# Catppuccin theme for supported terminal and editor integrations.
# Global switch (vars/features.nix): gates this module and every inline
# catppuccin theme string so all hosts switch themes together.
{
  config,
  lib,
  catppuccin,
  ...
}: {
  imports = lib.optionals (lib.modules ? importApply) [
    catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    # Upstream switch; with enable=false the imported module stays inert.
    enable = config.features.theme.catppuccin.enable;
    cache.enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "lavender"; # "blue", "flamingo", "green", "lavender", "maroon", "mauve", "peach", "pink", "red", "rosewater", "sapphire", "sky", "teal", "yellow"
    cursors.enable = false; # not supported for darwin
    cursors.accent = "mauve"; # "blue", "flamingo", "green", "lavender", "maroon", "mauve", "peach", "pink", "red", "rosewater", "sapphire", "sky", "teal", "yellow"
    vscode.profiles.default.enable = false; # disable automatic vscode extension management to avoid conflicts
  };
}
