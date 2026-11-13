# Android home stack

`default.nix` imports `compat.nix`, shared identity (`base/home.nix`), `base/core`, and `base/tui`. GUI modules are excluded. The stack sets `home.stateVersion = "24.05"`; optional programs are selected in [`home/hosts/android/pixel6.nix`](../hosts/android/pixel6.nix).

For system setup and package constraints, see the [Android host guide](../../hosts/android/README.md).

## Responsibilities

`default.nix` provides the Android-specific home behavior:

- Neovim, Git, and fzf from `pkgs.nixos2511`, selected through their program package options to avoid rebuilding unrelated dependents.
- A longer Starship command timeout for shared-storage repositories and an Android prompt glyph.
- Git's safe-directory setting for repositories under `/storage/emulated/0/`.
- Atuin without its systemd-dependent daemon.
- zsh syntax highlighting and a shared SSH agent.
- A real Maple Mono NF font file for Termux.

Other leaf TUI packages are replaced in the host's Home Manager package set in [`hosts/android/pixel6/default.nix`](../../hosts/android/pixel6/default.nix). Base package aliases needed by nvf are defined in `flake.nix`.

## Home Manager 24.05 compatibility

`compat.nix` bridges shared modules written against newer Home Manager APIs:

| Area            | Compatibility behavior                                                 |
| --------------- | ---------------------------------------------------------------------- |
| Shell           | Forward bash/zsh `initContent` to `initExtra`                          |
| Git             | Forward `settings` to `extraConfig`                                    |
| fzf             | Forward the file widget command; accept but ignore the history command |
| SSH             | Translate `settings` to HM 24.05 options and `matchBlocks`             |
| Atuin/tealdeer  | Declare unsupported newer options without implementing their effects   |
| herdr/worktrunk | Minimal package, TOML settings, and supported shell integrations       |

The backports do not implement herdr's `mutableSettings` or worktrunk's Claude Code integration. Adding a declaration alone does not add an upstream feature; document whether a shim forwards, implements, or ignores an option.

### SSH option precedence

HM 24.05 emits a `Host *` block from top-level options and appends `extraConfig` inside it. OpenSSH uses the first value found, so simply appending another wildcard block would not override those defaults.

The shim maps known `settings."*"` keys to HM's top-level options, named hosts to `matchBlocks`, and only the remaining wildcard keys to `extraConfig`.

## SSH agent

There is no systemd user service. zsh checks `~/.ssh/agent.sock` and starts one agent there when none is reachable; all shells share that socket. `AddKeysToAgent` adds keys on first use, so the passphrase remains cached until the agent exits or Android kills it.

## Font activation

The activation script copies Maple Mono NF from the Nix store to `~/.termux/font.ttf`. A store symlink is not sufficient for the native Termux font reader. The copy respects Home Manager dry-run mode.

Force-stop and reopen the app after switching if the font or login shell has changed. This stack configures the user environment; nix-on-droid system settings remain under [`hosts/android/`](../../hosts/android/README.md).
