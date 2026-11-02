# Linux home stacks

Stacks reserved for future NixOS hosts. No Linux host is currently configured.

- `core.nix`: shared identity + core + Linux CLI integrations (`base/`). Suitable
  for a minimal interactive server account.
- `tui.nix`: core plus terminal workstation tools.
- `gui.nix`: TUI plus cross-platform GUI and Linux desktop applications.

A NixOS host imports a stack through its system's Home Manager module. For
standalone HM on non-NixOS Linux, enable `targets.genericLinux` as a host choice;
it is not part of the shared stack. Add host entry points under
`home/hosts/linux/` when the first Linux host is wired up.
