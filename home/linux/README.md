# Linux home stacks

Reusable stacks for future NixOS hosts. No Linux host, `nixosConfigurations` output, or standalone Home Manager host is currently configured. Linux Neovim package outputs are separate from these stacks.

## Available layers

| Stack      | Imports                                                   | Intended use                |
| ---------- | --------------------------------------------------------- | --------------------------- |
| `core.nix` | Shared identity, core modules, Linux CLI integrations     | Minimal interactive account |
| `tui.nix`  | `core.nix` plus shared TUI modules                        | Terminal workstation        |
| `gui.nix`  | `tui.nix`, shared GUI modules, Linux desktop integrations | Desktop user                |

Importing a layer makes its options available; optional programs still need their `features.*` flags enabled.

## Wiring a future host

1. Create a system configuration and add its flake output.
2. Create `home/hosts/linux/<hostname>.nix` and import the desired stack.
3. Set host-specific feature flags in that entry point.
4. Wire the entry point through the system's Home Manager module and pass the repository's required module arguments.
5. Validate the full system and home configuration before activation.

For a future standalone Home Manager setup on non-NixOS Linux, enable `targets.genericLinux` as a host-specific choice. It is intentionally not enabled in the shared stack; such a setup would also require a new flake output.

See [Home Manager composition](../README.md) and the [host guide](../../hosts/README.md#future-nixos-hosts).
