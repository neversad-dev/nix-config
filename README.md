# Nix config

[![Built with Nix](https://img.shields.io/badge/Built_With-Nix-5277C3.svg?logo=nixos&labelColor=73C3D5)](https://nixos.org)
[![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=F0F0F0)](https://www.apple.com/macos)
[![Build Check](https://img.shields.io/github/actions/workflow/status/neversad-dev/nix-config/build-check.yml?branch=main&logo=github-actions&logoColor=white&label=build%20check)](https://github.com/neversad-dev/nix-config/actions/workflows/build-check.yml)
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)

Personal macOS and Android configurations built with [nix-darwin](https://github.com/nix-darwin/nix-darwin), [Home Manager](https://github.com/nix-community/home-manager), and [nix-on-droid](https://github.com/nix-community/nix-on-droid).

## Highlights

- **macOS system and user configuration** applied together through nix-darwin's embedded Home Manager module.
- **Android terminal environment** using nix-on-droid and Home Manager, pinned to release 24.05.
- **Layered home modules** (`base/core`, `base/tui`, `base/gui`) with optional programs controlled by `features.*` flags.
- **Catppuccin Mocha** across supported applications.
- **Encrypted machine secrets** managed with agenix/ragenix and a private `nix-secrets` input.
- **Standalone Neovim package** built from the in-repository nvf modules.

The Linux home stacks are reserved for future NixOS hosts; no Linux system or standalone Home Manager host is currently configured.

## Before you start

These are personal host configurations, not generic installation profiles. Review the username, SSH keys, feature flags, and secrets before applying them to another machine.

- Use a recent Nix release with `nix-command` and `flakes` enabled.
- The development shell provides `just`, `nh`, and the formatters. On macOS or conventional Linux, enter it with `nix develop`, or use `direnv` after allowing the repository's environment. On Android, avoid this unstable-based shell and automatic direnv activation; use the [on-device bootstrap commands](hosts/README.md#bootstrap-android) instead.
- The flake references a **private `nix-secrets` repository**. Normal evaluation may require SSH access to it, even when selecting only a package. To reuse the configuration, replace that input and its secret declarations. CI uses evaluation-only stubs, not deployable secrets.

For machine setup and SSH key enrollment, start with the [host bootstrap guide](hosts/README.md).

## Daily commands

Run these from the repository root after completing host setup:

```bash
just                     # list recipes
just darwin-build mbair  # build macOS without activating
just darwin mbair        # apply system + Home Manager configuration
just droid pixel6        # switch Android; run on-device
just up                  # update all inputs and commit flake.lock
just upp nixpkgs         # update one input and commit flake.lock
just fmt                 # format Nix, Markdown/YAML/JSON, Shell, and TOML
just clean               # remove old generations with nh (keep 3)
just nvim                # run the configured Neovim from this checkout
```

After host setup, `just darwin` and `just droid` can select the local host without an explicit name. Use `just droid-clean` for Android garbage collection.

The Neovim package can also be selected remotely with `nix run github:neversad-dev/nix-config`; see the private-input caveat above.

## Hosts and outputs

| Host   | Platform                | System configuration    | Home Manager entry point        |
| ------ | ----------------------- | ----------------------- | ------------------------------- |
| mbair  | macOS / aarch64-darwin  | `hosts/mbair/`          | `home/hosts/darwin/mbair.nix`   |
| pixel6 | Android / aarch64-linux | `hosts/android/pixel6/` | `home/hosts/android/pixel6.nix` |

`flake.nix` provides:

- `darwinConfigurations.mbair`: macOS system with embedded Home Manager.
- `nixOnDroidConfigurations.pixel6`: Android environment with built-in Home Manager integration.
- `packages.<system>.nvim` and `.default`: configured Neovim for `aarch64-darwin`, `aarch64-linux`, and `x86_64-linux`.
- `devShells.<system>.default` and `formatter.<system>`: development tools and the Nix formatter.

`homeConfigurations` is empty. Local helpers (`mylib`) and identity values (`myvars`) are module arguments, not exported flake library outputs.

## Repository layout

```text
.
├── flake.nix                    # Host outputs, Neovim package, development shell
├── Justfile                     # Build, switch, update, and formatting recipes
├── hosts/                       # Per-host system configurations
│   ├── mbair/
│   └── android/pixel6/
├── modules/
│   ├── common/                  # Shared system imports and option definitions
│   └── darwin/                  # macOS settings, services, and Homebrew
├── home/
│   ├── base/                    # Shared identity and core/tui/gui modules
│   │   └── tui/neovim/          # Home Manager integration and nvf modules
│   ├── darwin/                  # macOS user stack
│   ├── linux/                   # Future NixOS user stacks
│   ├── android/                 # Android stack and HM 24.05 compatibility
│   └── hosts/                   # Per-host Home Manager entry points
├── lib/                         # Local module and editable-config helpers
├── secrets/                     # Darwin secret declarations and enrollment guide
├── vars/                        # Identity, shared feature options, and fonts
├── overlays/                    # Additional package sets and customizations
└── pkgs/                        # Custom packages
```

## Documentation

| Topic                      | Guide                                         |
| -------------------------- | --------------------------------------------- |
| Bootstrap or add a host    | [Hosts](hosts/README.md)                      |
| Home Manager composition   | [Home modules](home/README.md)                |
| Feature flags and identity | [Variables](vars/README.md)                   |
| Secret enrollment          | [Secrets](secrets/README.md)                  |
| Android constraints        | [nix-on-droid](hosts/android/README.md)       |
| Neovim and CodeCompanion   | [Neovim](home/base/tui/neovim/README.md)      |
| Local helper functions     | [Library](lib/README.md)                      |
| CI behavior                | [GitHub Actions](.github/workflows/README.md) |

Package channels are defined in `flake.nix` and `overlays/default.nix`: macOS uses unstable by default with `pkgs.stable` for the 26.05 fallback; Android uses 24.05 with selected `pkgs.nixos2511` packages. Project tasks live in `todo.txt`, managed with `just todo` and related recipes.

## Validation

Before committing configuration changes:

```bash
just fmt
nix flake check --accept-flake-config
just fmt-check
just darwin-build mbair
```

Android additionally needs its Home Manager generation evaluated and interactive tools tested on-device; `nix flake check` does not validate `nixOnDroidConfigurations`. CI performs that evaluation explicitly. See the [workflow guide](.github/workflows/README.md) for coverage and limitations, including dry-run builds.

## License

MIT.
