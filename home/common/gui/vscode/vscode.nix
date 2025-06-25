{pkgs, ...}: let
  commonSettings = (import ./common.nix {inherit pkgs;}).commonSettings;
in {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    mutableExtensionsDir = true;

    profiles.default.userSettings = commonSettings;

    profiles.default.extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons

      # Code Fromatting and Quality
      esbenp.prettier-vscode # formatter
      oderwat.indent-rainbow

      # Development Tools
      christian-kohler.path-intellisense # Autocompletes filenames
      naumovs.color-highlight # Highlights color codes in your code
      gruntfuggly.todo-tree #  Shows TODO comments in a tree view

      # Markdown Support
      bierner.github-markdown-preview
      bierner.markdown-preview-github-styles
      bierner.markdown-emoji
      bierner.markdown-checkbox
      # bierner.markdown-yaml-preamble
      bierner.markdown-footnotes
      bierner.markdown-mermaid
      # bierner.markdown-image-size
      davidanson.vscode-markdownlint

      # Nix Support
      jeff-hykin.better-nix-syntax
      jnoortheen.nix-ide
      kamadorueda.alejandra

      # Language Support
      redhat.java # Java support
      mathiasfrohlich.kotlin # Kotlin support
      nefrob.vscode-just-syntax # Just syntax highlighting
      mads-hartmann.bash-ide-vscode # Bash IDE features
      timonwong.shellcheck # Shell script linting
      redhat.vscode-xml # XML support
      redhat.vscode-yaml # YAML support
      tamasfe.even-better-toml # TOML support
      mechatroner.rainbow-csv # CSV file support
      zainchen.json # JSON support
      irongeek.vscode-env # .env file support
    ];
  };
}
