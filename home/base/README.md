# Cross-platform home modules

- `home.nix`: user identity, home directory defaults, compatibility state version,
  fallback Vim editor and Nix settings. Platform stacks import it explicitly.
- `core/`: shared shell, Git, SSH, direnv and lightweight CLI baseline. Starship
  and Neovim are opt-in (`features.cli.{starship,neovim}.enable`, default false).
- `tui/`: workstation tools, Git extras, AI agent, Catppuccin and user-level
  agenix. Includes [`tui/neovim/`](tui/neovim/README.md), a Home Manager module
  that enables nvf and feeds the sibling nvf modules into `programs.nvf`.
  Not required for minimal servers or Android's core stack.
- `gui/`: cross-platform desktop editors, terminal emulators, wallpapers and fonts.

Basic Git is always available from core. `features.cli.git.enable` gates the
TUI Git extras; `features.cli.git.signing.enable` additionally enables signing.
Android selectively imports that extras directory without the whole TUI stack.

Import through a [platform stack](../README.md), not directly from flake outputs.
