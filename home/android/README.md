# Android home stack

`default.nix` imports `compat.nix`, `base/home.nix`, `base/core` and `base/tui`,
and selects `home.stateVersion = "24.05"`. GUI modules are not imported. Which
optional features are on is decided by the host flags in
`home/hosts/android/pixel6.nix`.

Phone-specific settings live in `default.nix`:

- packages from nixos-25.11 where 24.05 is too old (Neovim, Git, fzf via
  `programs.<x>.package`; leaf TUI packages are swapped in
  `hosts/android/pixel6/default.nix`)
- Starship prompt timeout and Android OS glyph, Atuin without its daemon
- zsh: ssh-agent startup and syntax highlighting
- Termux font activation

## compat.nix

Translates newer shared HM options for HM 24.05: shell init (`initContent`),
Git settings, fzf file widget, SSH settings. Unsupported Atuin/tealdeer options
are declarations only. herdr and worktrunk (no HM 24.05 modules) have minimal
backports: package, `config.toml`, and zsh integration for worktrunk (no herdr
`mutableSettings`, no worktrunk Claude Code integration). The removed
`fzf.historyWidgetCommand` is not forwarded.

SSH: HM 24.05 always renders its own `Host *` block from top-level options
(`addKeysToAgent`, `controlMaster`, ...) and appends `extraConfig` inside it.
OpenSSH uses the first value it finds, so `settings."*"` is mapped onto those
options, named hosts onto `matchBlocks`, and only `"*"` keys without an HM
option go to `extraConfig`.

## ssh-agent

No systemd, so zsh starts one agent on `~/.ssh/agent.sock` when none is
reachable; all shells share it. Keys are added lazily by `AddKeysToAgent`, so
the passphrase is asked on first use and cached until Android kills the agent.

The system layer remains in [hosts/android](../../hosts/android/README.md).
