# Shared home modules

These modules are building blocks for the [platform stacks](../README.md), not standalone host configurations. Platforms import the layers they need; the layers are not automatically cumulative.

## Layers

| Module     | Responsibility                                                                 |
| ---------- | ------------------------------------------------------------------------------ |
| `home.nix` | Identity and home defaults, compatibility state version, Vim, and Nix settings |
| `core/`    | Shell, Git, GitHub CLI, SSH, and lightweight CLI integrations                  |
| `tui/`     | Terminal tools, Git extras, Neovim, AI, and Catppuccin integration             |
| `gui/`     | Desktop editors, terminal emulators, wallpapers, and fonts                     |

Importing a directory makes its modules available. Optional integrations still require their `features.*` flags; for example, importing `tui/` does not enable Neovim until `features.cli.neovim.enable = true`.

[`tui/neovim/`](tui/neovim/README.md) contains both a Home Manager module and nvf settings modules. The latter run inside `programs.nvf.settings`, not the ordinary Home Manager module context.

## Git controls

The Git binary is always enabled by the core stack. Its configuration uses these feature flags:

- `features.cli.git.core.enable`: identity, ignores, aliases, and commit template.
- `features.cli.git.extended.enable`: Delta, lazygit, and worktrunk.
- `features.cli.git.signing.enable`: SSH commit signing; also requires `features.cli.git.extended.enable`.

## Cross-platform requirements

- Keep shared modules compatible with Android's Home Manager 24.05. Add supported option translations to [`android/compat.nix`](../android/compat.nix) when needed.
- Integrations that require newer upstream modules, such as Catppuccin and pi, guard their imports with `isHm24`.
- New interactive Android packages need on-device testing; do not assume unstable binaries work in proot.
- Read managed secrets from system-provided runtime paths on Darwin. Do not embed secret contents in generated Nix-store files.

Prefer Home Manager program options, package defaults, and small feature-gated modules. Platform-specific behavior belongs under `home/darwin`, `home/linux`, or `home/android`.
