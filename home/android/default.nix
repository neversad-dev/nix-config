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

  # nix-on-droid hardcodes these (from its 24.05 pkgs) in its base env;
  # HM brings unstable copies. Same-priority duplicates collide in
  # nix-on-droid-path, so let the unstable ones win. mkBefore matters:
  # buildEnv keeps only the *first* occurrence of a store path, so the
  # hiPrio copies must precede the plain ones from other modules.
  home.packages = lib.mkMerge [
    (lib.mkBefore (map lib.hiPrio [pkgs.bashInteractive pkgs.coreutils]))
    [pkgs.procps]
  ];

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
    fontStorePath="${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFont-Regular.ttf"
    targetDir="${config.home.homeDirectory}/.termux"
    mkdir -p "$targetDir"
    if [ -e "$fontStorePath" ]; then
      cp -f "$fontStorePath" "$targetDir/font.ttf"
    fi
  '';
}
