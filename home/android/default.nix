{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./compat.nix
    ./acode.nix
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

  # Starship detects OS from /etc/os-release at runtime; inside nix-on-droid's
  # proot that resolves to generic "Linux" (penguin). Show the Android glyph.
  programs.starship.settings.os.symbols.Linux =
    lib.mkForce " "; # nf-fa-android (U+F17B), same as os.symbols.Android

  # Atuin daemon relies on systemd user services (not available on
  # nix-on-droid) — run without it; sqlite direct access is fine.
  programs.atuin.daemon.enable = false;

  # From nixos-25.11 via the package option rather than the HM pkgs overlay
  # (hosts/android/pixel6): many packages depend on these, and overriding
  # them in the package set forces hundreds of uncached rebuilds.
  programs.git.package = pkgs.nixos2511.git;

  # Shared storage (/storage/emulated/0) is owned by another Android user, so
  # git refuses repos there ("dubious ownership"). Declared here because
  # `git config --global` writes ~/.gitconfig, which core.nix removes on
  # every switch. Trailing /* matches everything below (git >= 2.46).
  programs.git.settings.safe.directory = "/storage/emulated/0/*";
  programs.fzf.package = pkgs.nixos2511.fzf;

  # HM-24.05's highlighting can conflict with Atuin's zle bindings.
  # Also: no systemd on nix-on-droid, so start ssh-agent from the shell.
  programs.zsh.initExtra = ''
    # ssh-agent (HM's agent service needs systemd, absent here).
    # One agent on a fixed socket, shared by all shells. Started only if
    # unreachable; the key is added lazily by AddKeysToAgent on first use.
    # NB: don't name variables `status` here — it's read-only in zsh, and
    # the error aborts the rest of .zshrc (starship, aliases, ...).
    export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
    ssh-add -l > /dev/null 2>&1
    if [ $? -eq 2 ]; then
      rm -f "$SSH_AUTH_SOCK"
      ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null
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
