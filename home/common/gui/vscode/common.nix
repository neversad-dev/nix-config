{pkgs, ...}: {
  commonSettings = {
    # Editor settings
    "editor.fontFamily" = "FiraCode Nerd Font Mono";
    "editor.fontLigatures" = true;
    "editor.fontSize" = 14;
    "editor.formatOnSave" = true;
    "editor.formatOnPaste" = false;
    "editor.inlineSuggest.enabled" = true;
    "editor.lineHeight" = 0;
    "editor.linkedEditing" = true;
    "editor.minimap.enabled" = false;
    "editor.multiCursorModifier" = "ctrlCmd";
    "editor.snippetSuggestions" = "top";
    "editor.suggestSelection" = "first";
    "editor.tabSize" = 4;
    "editor.semanticHighlighting.enabled" = true;

    # File settings
    "files.autoSave" = "afterDelay";
    "files.autoSaveDelay" = 800;

    # Workbench settings
    "workbench.colorTheme" = "Catppuccin Mocha";
    "workbench.editor.labelFormat" = "medium";
    "workbench.editor.showTabs" = "none";
    "workbench.iconTheme" = "catppuccin-mocha";
    "workbench.startupEditor" = "newUntitledFile";

    # Telemetry settings
    "telemetry.telemetryLevel" = "off";
    "redhat.telemetry.enabled" = false;

    # Git settings
    "git.autofetch" = true;
    "git.openRepositoryInParentFolders" = "never";

    # Nix settings
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "nixd";
    "nixpkgs" = {
      "expr" = "import (builtins.getFlake \"/home/neversad/nix-darwin\").inputs.nixpkgs { }";
    };
    "options" = {
      "nixos" = {
        "expr" = "(builtins.getFlake \"/home/neversad/nix-darwin\").nixosConfigurations.CONFIGNAME.options";
      };
      "darwin" = {
        "expr" = "(builtins.getFlake \"/home/neversad/nix-darwin\").darwinConfigurations.CONFIGNAME.options";
      };
      "home_manager" = {
        "expr" = "(builtins.getFlake \"/home/neversad/nix-darwin\").homeConfigurations.CONFIGNAME.options";
      };
    };

    # Using the light mode
    "indentRainbow.indicatorStyle" = "light";
    # we use a simple 1 pixel wide line
    "indentRainbow.lightIndicatorStyleLineWidth" = 1;
    # the same colors as above but more visible
    "indentRainbow.colors" = [
      "rgba(243, 139, 168, 0.3)" # #f38ba8
      "rgba(250, 181, 135, 0.3)" # #fab387
      "rgba(249, 226, 175, 0.3)" # #f9e2af
      "rgba(166, 227, 161, 0.3)" # #a6e3a1
      "rgba(137, 180, 250, 0.3)" # #89b4fa
      "rgba(203, 166, 247, 0.3)" # #cba6f7
    ];

    "editor.defaultFormatter" = "esbenp.prettier-vscode";
    # Language-specific settings
    "[nix]" = {
      "editor.defaultFormatter" = "kamadorueda.alejandra";
    };
    "alejandra.program" = "${pkgs.alejandra}/bin/alejandra";

    "[shellscript]" = {
      "editor.defaultFormatter" = "mkhl.shfmt";
    };

    "[markdown]" = {
      "editor.defaultFormatter" = "DavidAnson.vscode-markdownlint";
    };
  };
}
