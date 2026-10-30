# nix-on-droid (Pixel 6)

Nix-on-Droid configuration for Pixel 6 (aarch64-linux). This is a **proot-based** Android Nix environment using the `nix-on-droid` flake from `nix-community/nix-on-droid/release-24.05`.

## Key constraints

- **Pinned to 24.05**: nix-on-droid, its pkgs (`nixpkgs-24-05`) and its bundled Home Manager (`home-manager-24-05`) are on release-24.05, so `system.stateVersion` and `home.stateVersion` are `24.05`.
- **No unstable binaries for interactive tools**: unstable's glibc (>= 2.42) uses the `TCGETS2` ioctl, which Android's SELinux blocks on ttys (no prompt/TUI, `stty: Permission denied`). Newer packages come from **nixos-25.11** (`pkgs.nixos2511`, still glibc 2.40). `pkgs.unstable` is only for non-interactive CLI tools, plus TUIs verified to work on-device (tuxedo, herdr, worktrunk).
- **Shared modules, HM 24.05 shims**: the phone uses the same `home/base` modules as the desktops. Options introduced after HM 24.05 are polyfilled in [`home/android/compat.nix`](../../home/android/compat.nix).

## File layout

| File                                                                   | Purpose                                                                                                                                   |
| ---------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `pixel6/default.nix`                                                   | System layer: login shell, timezone, Nix settings, and the `home-manager` block (HM-scoped 25.11 package overrides, `isHm24 = true`).     |
| `pixel6/secrets.nix`                                                   | Placeholder: nix-on-droid has no system-level secrets; user secrets would go through `home/base/tui/secrets.nix` (disabled on the phone). |
| [`home/hosts/android/pixel6.nix`](../../home/hosts/android/pixel6.nix) | Home entry point: `features.*` flags for the phone.                                                                                       |
| [`home/android/`](../../home/android/README.md)                        | Android home stack: `compat.nix` polyfills, ssh-agent, Termux font, 25.11 package choices.                                                |

The pkgs set itself (24.05 + overlays, plus 25.11 aliases for packages nvf's language presets need) is built in `flake.nix` under `nixOnDroidConfigurations.pixel6`.

## Architecture notes

### Flake inputs and HM-version-dependent modules

Flake `inputs` are passed to Home Manager via `home-manager.extraSpecialArgs`, like on the desktops. Modules whose upstream HM module needs a newer HM (Catppuccin, pi) check `isHm24` and skip themselves on the phone.

### Font setup

Termux reads a **real file** (not a symlink) from `~/.termux/font.ttf`. The store path is not resolvable from Android's native font layer, so home-manager's `home.file` with `.source` doesn't work.

Solution: `home.activation.copyTermuxFont` copies the JetBrainsMono Nerd Font from `/nix/store` into `~/.termux/font.ttf` on every switch.

### SSH agent

There is no systemd (or keychain), so zsh starts `ssh-agent` on a fixed socket (`~/.ssh/agent.sock`) when none is reachable. The key is added on first use via `AddKeysToAgent`: the passphrase is asked once and cached until Android kills the agent (e.g. when the app is fully closed).

### Known issues

- No system monitor: Android blocks `/proc/stat` for apps (since Android 8),
  so btop can't read CPU stats in any version. `htop` and `procs` are
  installed but show no/partial CPU data.
- `tmux` was removed entirely from the repo (not just skipped).

## Usage

```bash
# Switch from local checkout (useful while iterating)
cd /storage/emulated/0/code/projects/nix-config && git pull
just droid          # uses $HOSTNAME, set by HM once the first switch is done
just droid pixel6   # first switch (HOSTNAME not set yet)

# Or without just
nix-on-droid switch --flake "path:/storage/emulated/0/code/projects/nix-config#pixel6"

# Switch from GitHub (useful once everything is stable)
nix-on-droid switch --flake github:neversad-dev/nix-config#pixel6
```

After switching, **force-stop and reopen** the nix-on-droid app so Termux picks up the copied font and login-shell changes.

`just droid-clean` deletes old generations and garbage-collects the store.

## What's enabled

See the `features` flags in [`home/hosts/android/pixel6.nix`](../../home/hosts/android/pixel6.nix).
