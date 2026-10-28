# Android home stack

`default.nix` imports `base/home.nix`, `base/core` and `compat.nix`, and selects
`home.stateVersion = "24.05"`. Neovim and Starship default to disabled; Pixel 6
explicitly enables Starship and imports the lightweight TUI Git extras.

`compat.nix` translates newer shared HM options for HM 24.05 (shell init,
Git settings, SSH settings, fzf file widget). Unsupported Atuin/tealdeer options
and worktrunk are declarations only, not backported implementations. The removed
`fzf.historyWidgetCommand` is not forwarded.

SSH host settings are rendered as raw SSH configuration, with specific hosts
before `Host *`. No full workstation TUI/GUI stack or agenix is needed here.

Phone-specific prompt timeout, zsh highlighting fix and Termux font activation
live in `home/hosts/android/pixel6.nix`. The system layer remains in
[hosts/android](../../hosts/android/README.md).
