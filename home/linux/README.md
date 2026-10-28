# Linux home stacks

- `core.nix`: shared identity + core + Linux CLI integrations (`base/`). Suitable
  for a minimal interactive server account; HM itself is optional on servers.
- `tui.nix`: core plus terminal workstation tools.
- `gui.nix`: TUI plus cross-platform GUI and Linux desktop applications.

`targets.genericLinux.enable` is a host choice, not part of core: enable it for
standalone HM on non-NixOS Linux (as enduro does), not automatically on NixOS.
Host choices live in `home/hosts/linux/`.
