{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./compat.nix
    ../base/home.nix
    ../base/core
    ../base/tui
  ];

  home.stateVersion = "24.05";

  # Basic userland that nix-on-droid doesn't ship.
  # Unstable packages: use pkgs.unstable.<name> for non-interactive CLI
  # tools only (see flake.nix nixOnDroidConfigurations for why).
  home.packages = with pkgs; [procps gnugrep gnused findutils];

  # nvf plugins need Neovim >= 0.10 (24.05 has 0.9.5); unstable's build is
  # unusable on Android (glibc TCGETS2), so take 0.11 from nixos-25.11.
  programs.nvf.settings.vim.package = pkgs.nixos2511.neovim-unwrapped;

  # Background git checks can time out on Android's shared storage.
  programs.starship.settings.command_timeout = 2000;

  # Atuin daemon relies on systemd user services (not available on
  # nix-on-droid) — run without it; sqlite direct access is fine.
  programs.atuin.daemon.enable = false;
  # Newer atuin (24.05 has 18.2), still glibc 2.40 so its TUI works.
  programs.atuin.package = pkgs.nixos2511.atuin;

  # HM-24.05's highlighting can conflict with Atuin's zle bindings.
  programs.zsh.initExtra = ''
    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  '';

  # Termux needs a real file, not a symlink into the Nix store.
  home.activation.copyTermuxFont = lib.hm.dag.entryAfter ["writeBoundary"] ''
    fontStorePath="${pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];}}/share/fonts/truetype/NerdFonts/JetBrainsMonoNerdFont-Regular.ttf"
    targetDir="${config.home.homeDirectory}/.termux"
    mkdir -p "$targetDir"
    if [ -e "$fontStorePath" ]; then
      cp -f "$fontStorePath" "$targetDir/font.ttf"
    fi
  '';
}
