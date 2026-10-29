{
  config,
  lib,
  pkgs,
  outputs,
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
  home.packages =
    (with pkgs; [procps gnugrep gnused findutils])
    # Neovim from unstable: nvf presets need packages missing in 24.05.
    # Reuses the flake's standalone nvim (same config, built on unstable).
    ++ lib.optional config.features.cli.neovim.enable
    outputs.packages.${pkgs.stdenv.hostPlatform.system}.nvim;

  # programs.nvf.finalPackage is read-only, so bypass the HM module.
  programs.nvf.enable = lib.mkForce false;
  home.sessionVariables = lib.mkIf config.features.cli.neovim.enable {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Background git checks can time out on Android's shared storage.
  programs.starship.settings.command_timeout = 2000;

  # Atuin daemon relies on systemd user services (not available on
  # nix-on-droid) — run without it; sqlite direct access is fine.
  programs.atuin.daemon.enable = false;

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
