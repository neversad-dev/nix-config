# Android host: Pixel 6

An `aarch64-linux`, proot-based Nix environment using [nix-on-droid release 24.05](https://github.com/nix-community/nix-on-droid/tree/release-24.05). This configures the terminal environment, not Android's operating system.

## Compatibility constraints

- **Base releases stay on 24.05.** nix-on-droid, its base nixpkgs, and its Home Manager input are pinned together. Both system and home compatibility state versions are `24.05`.
- **Interactive unstable binaries are unsafe by default.** glibc 2.42 and newer use the `TCGETS2` ioctl, which Android's SELinux blocks on ttys. Symptoms include a missing prompt, broken TUIs, and `stty: Permission denied`.
- **Use `pkgs.nixos2511` for newer interactive tools.** This package set stays below that glibc boundary. Unstable packages require on-device verification; tuxedo, herdr, and worktrunk are explicit exceptions already used here, not evidence that every unstable TUI works.
- **Shared modules need HM 24.05 compatibility.** Newer option names are translated or declared in [`home/android/compat.nix`](../../home/android/compat.nix); integrations such as the upstream Catppuccin and pi HM modules skip themselves via `isHm24`.
- **No managed secrets.** The Android secrets module is a placeholder. Evaluation may still need access to the private `nix-secrets` flake input; see the [root prerequisites](../../README.md#before-you-start).

## Configuration map

| Location                                                               | Responsibility                                             |
| ---------------------------------------------------------------------- | ---------------------------------------------------------- |
| `pixel6/default.nix`                                                   | Shell, timezone, Nix settings, embedded HM, leaf overrides |
| `pixel6/secrets.nix`                                                   | Placeholder; no agenix integration                         |
| [`home/hosts/android/pixel6.nix`](../../home/hosts/android/pixel6.nix) | Phone feature flags and `HOSTNAME`                         |
| [`home/android/default.nix`](../../home/android/default.nix)           | Android user behavior and program package selections       |
| [`home/android/compat.nix`](../../home/android/compat.nix)             | HM 24.05 compatibility shims                               |
| [`flake.nix`](../../flake.nix)                                         | Base package set, overlays, nvf language-package aliases   |

Widely used packages such as Git and fzf are selected through `programs.<name>.package`; replacing them throughout the package set would rebuild their dependents. Leaf TUI overrides are scoped to Home Manager in the system host module.

## Build and switch

Run inside **nix-on-droid on the device**, from the repository root:

```bash
just droid-build pixel6  # build without switching
just droid pixel6        # apply system and Home Manager configuration
```

After the first switch, open a new shell to receive `HOSTNAME=pixel6`; plain `just droid` then selects the host. A checkout on Android shared storage can be used, provided the app has the required storage permissions.

Without a local checkout, the direct remote switch is:

```bash
nix-on-droid switch --flake github:neversad-dev/nix-config#pixel6
```

The same private-input access requirements apply. Do not use CI stub inputs for activation.

Force-stop and reopen the app after changing the login shell or font. `just droid-clean` deletes old generations and garbage-collects the store; it removes rollback history, so use it only after verifying the new configuration.

## Validation

On-device builds and interactive testing are authoritative. For evaluation on another platform, CI checks only the Home Manager derivation path:

```bash
nix eval --raw .#nixOnDroidConfigurations.pixel6.config.home-manager.config.home.activationPackage.drvPath
```

`nix flake check` alone does not validate `nixOnDroidConfigurations`, and CI does not build or activate the Android environment. See the [workflow guide](../../.github/workflows/README.md).

## Runtime notes

### Fonts

The native Termux font reader needs a real file at `~/.termux/font.ttf`; a symlink into the Nix store is insufficient. Home activation copies Maple Mono NF there on each switch. See the [Android home stack](../../home/android/README.md#font-activation).

### SSH agent

zsh shares one `ssh-agent` on `~/.ssh/agent.sock`. Keys are added on first use through `AddKeysToAgent`; the passphrase remains cached until the agent exits or Android kills it. There is no systemd user service or macOS Keychain integration.

### Process monitors

Android restricts access to `/proc/stat`, so btop is disabled. The available `htop` and `procs` tools may show incomplete or no CPU data; changing package versions does not remove the platform restriction.

### Acode

For Acode's Git SCM plugin on the same repositories, see [acode.md](acode.md).

Enabled programs are listed in [`home/hosts/android/pixel6.nix`](../../home/hosts/android/pixel6.nix). General enrollment and setup are covered by the [host bootstrap guide](../README.md#bootstrap-android).
