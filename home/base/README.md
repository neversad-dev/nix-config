# Cross-platform home modules

- `home.nix`: user identity, home directory defaults, compatibility state version,
  fallback Vim editor and Nix settings. Platform stacks import it explicitly.
- `core/`: shared shell, Git, SSH, direnv and lightweight CLI baseline. Starship
  and Neovim are opt-in (`features.cli.{starship,neovim}.enable`, default false).
- `tui/`: workstation tools, Git extras, AI agent and Catppuccin. Includes
  [`tui/neovim/`](tui/neovim/README.md), a Home Manager module that enables nvf
  and feeds the sibling nvf modules into `programs.nvf`. Not required for
  minimal servers.
- `gui/`: cross-platform desktop editors, terminal emulators, wallpapers and fonts.

The git binary is always available from core (unconditional `programs.git`).
`features.cli.git.core.enable` gates core Git configuration (identity, ignores,
aliases, commit template); `features.cli.git.extended.enable` gates the TUI Git extras;
`features.cli.git.signing.enable` additionally enables signing.
Modules that need a newer HM than 24.05 (Catppuccin, pi) skip themselves when
`isHm24` is set (nix-on-droid).

Import through a [platform stack](../README.md), not directly from flake outputs.
