# nix-on-droid (Pixel 6)

Nix-on-Droid configuration for Pixel 6 (aarch64-linux). This is a **proot-based** Android Nix environment using the `nix-on-droid` flake from `nix-community/nix-on-droid/release-24.05`.

## Key constraints

- **Must stay on NixOS 24.05**: `system.stateVersion` and `home.stateVersion` are pinned to `24.05` because the nix-on-droid release, `nixpkgs-24-05`, and `home-manager-24-05` are all pinned in `flake.nix`.
- **Heavy reuse with caveats**: Most CLI modules are shared with `mbair` (which targets HM 24.11). Any option introduced after HM 24.05 must be **polyfilled** in `compat.nix` so the shared modules evaluate without modification.
- **Cherry-pick imports**: We import individual `home/features/cli/*.nix` modules one by one instead of pulling in `cli/default.nix` wholesale. This keeps the surface area small and makes it easy to roll back anything that breaks in proot.

## File layout

| File               | Purpose                                                                                                                                                                                     |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `nix-on-droid.nix` | Top-level host config. Defines system packages, login shell, and the `home-manager` block that imports shared modules.                                                                      |
| `compat.nix`       | HM 24.05 polyfill. Declares newer option names (`initContent`, `git.settings`, `atuin.daemon`, etc.) and forwards their values to the 24.05 equivalents so shared modules evaluate cleanly. |

## Architecture notes

### Why no `inputs` in `home-manager.extraSpecialArgs`?

Nix-on-droid's bundled HM 24.05 does **not** forward flake `inputs` into the home-manager module scope. Any module that depends on flake inputs (e.g. the Catppuccin module from `inputs.catppuccin.homeModules`) must either:

1. Be imported at the **flake level** (outside the nix-on-droid home-manager block), or
2. Be **skipped** and replaced by a local stub.

This is why `compat.nix` is used heavily for forward declarations.

### Font setup

Termux reads a **real file** (not a symlink) from `~/.termux/font.ttf`. The store path is not resolvable from Android's native font layer, so home-manager's `home.file` with `.source` doesn't work.

Solution: `home.activation.copyTermuxFont` copies the JetBrainsMono Nerd Font from `/nix/store` into `~/.termux/font.ttf` on every switch.

### Known issues

- `btop` was removed: `/proc/stat` parsing fails inside proot.
- `tmux` was removed entirely from the repo (not just skipped).

## Usage

```bash
# Switch from local checkout (useful while iterating)
cd /storage/emulated/0/code/projects/nix-config && git pull
nix-on-droid switch --flake "path:/storage/emulated/0/code/projects/nix-config#default"

# Switch from GitHub (useful once everything is stable)
nix-on-droid switch --flake github:neversad-dev/nix-config#default
```

After switching, **force-stop and reopen** the nix-on-droid app so Termux picks up the copied font and login-shell changes.

## Currently enabled

System-level: `git`, `curl`, `vim`
Home-manager: `zsh`, `zoxide`, `fzf`, `fd`, `tree`, `git+delta+lazygit+worktrunk`, `starship`, `atuin`, `bat`, `htop`, `jq`, `yq`, `ripgrep`, `zip`, `python3`
