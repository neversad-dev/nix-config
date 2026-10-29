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

  # From nixos-25.11 via the package option rather than the HM pkgs overlay
  # (hosts/android/pixel6): many packages depend on these, and overriding
  # them in the package set forces hundreds of uncached rebuilds.
  programs.git.package = pkgs.nixos2511.git;
  programs.fzf.package = pkgs.nixos2511.fzf;

  # HM-24.05's highlighting can conflict with Atuin's zle bindings.
  # Also: no systemd on nix-on-droid, so start ssh-agent from the shell.
  programs.zsh.initExtra = ''
    # ssh-agent (HM's agent service needs systemd, absent here)
    # Verify the agent is reachable; if not, kill stale agents and start a
    # fresh one.  Do NOT ssh-add here — let ssh's AddKeysToAgent=yes load
    # the key on first use, so you only type the passphrase when you actually
    # pull/push, yet it's cached for the rest of the session.
    if [ -f "$HOME/.ssh/agent.env" ]; then
      . "$HOME/.ssh/agent.env" > /dev/null
    fi
    ssh-add -l > /dev/null 2>&1
    agent_status=$?
    if [ "$agent_status" -eq 2 ]; then
      pkill -u "$(id -u)" ssh-agent 2>/dev/null || true
      rm -f "$HOME/.ssh/agent.env"
      ssh-agent -s > "$HOME/.ssh/agent.env"
      . "$HOME/.ssh/agent.env" > /dev/null
    fi
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
