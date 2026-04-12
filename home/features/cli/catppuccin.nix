{catppuccin, ...}: {
  imports = [
    catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "lavender"; # "blue", "flamingo", "green", "lavender", "maroon", "mauve", "peach", "pink", "red", "rosewater", "sapphire", "sky", "teal", "yellow"
    cursors.enable = false; # not supported for darwin
    cursors.accent = "mauve"; # "blue", "flamingo", "green", "lavender", "maroon", "mauve", "peach", "pink", "red", "rosewater", "sapphire", "sky", "teal", "yellow"
    vscode.profiles.default.enable = false; # disable automatic vscode extension management to avoid conflicts
  };
}
