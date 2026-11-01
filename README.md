# Nix config

[![Built with Nix](https://img.shields.io/badge/Built_With-Nix-5277C3.svg?logo=nixos&labelColor=73C3D5)](https://nixos.org)
[![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=F0F0F0)](https://www.apple.com/macos)
[![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![Build Check](https://img.shields.io/github/actions/workflow/status/neversad-dev/nix-config/build-check.yml?branch=main&logo=github-actions&logoColor=white&label=build%20check)](https://github.com/neversad-dev/nix-config/actions/workflows/build-check.yml)
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)

nix-darwin + Home Manager flake (macOS + Linux), plus [nix-on-droid](https://github.com/nix-community/nix-on-droid) for Android.

## What lives here

- **Declarative macOS** via [nix-darwin](https://github.com/nix-darwin/nix-darwin) + Home Manager.
- **Declarative Linux desktops** via Home Manager (no NixOS servers yet).
- **Declarative Android** via nix-on-droid.
- **Layered home modules** under `home/` (`base/core` → `base/tui` → `base/gui`); optional pieces toggled with `features.*` flags.
- **Encrypted secrets** via agenix/ragenix in a private `nix-secrets` repo.
- **Catppuccin** everywhere.

## Quick start

```bash
just darwin  # macOS switch: nix-darwin system + embedded Home Manager
just home    # Home Manager only (fast iteration on HM changes)
just droid   # nix-on-droid switch on-device
just up      # update flake inputs
nix run github:neversad-dev/nix-config  # run the configured Neovim standalone
```

> On macOS, Home Manager is embedded in nix-darwin: `just darwin` applies both the
> system (dock, defaults, packages) and user config (dotfiles, SSH, git, shell).
> The standalone `neversad@mbair` output stays for HM-only iteration via `just home`.
> On Linux (enduro), `just home` is the only switch.
>
> Full command list: `just --list`

> Dev tooling (`nh`, `just`, `alejandra`, etc.) comes from the nix `devShell`. `direnv` auto-activates it when you `cd` into the repo.

## Hosts

| Host       | Platform               | Entrypoint                   |
| ---------- | ---------------------- | ---------------------------- |
| **mbair**  | macOS / aarch64        | `hosts/mbair/` (HM embedded) |
| **enduro** | Linux / x86_64         | HM only: `neversad@enduro`   |
| **pixel6** | Android (nix-on-droid) | `hosts/android/pixel6/`      |

Adding a new machine? See [hosts/README.md](hosts/README.md).

## Where to find what

| Topic                                      | Location                                                                             |
| ------------------------------------------ | ------------------------------------------------------------------------------------ |
| Bootstrap a new Mac / Linux machine        | [`hosts/README.md`](hosts/README.md)                                                 |
| How secrets work (agenix)                  | [`secrets/README.md`](secrets/README.md)                                             |
| Editing `features.*` flags                 | [`vars/README.md`](vars/README.md)                                                   |
| Home Manager structure                     | [`home/README.md`](home/README.md)                                                   |
| CI & automated checks                      | [`.github/workflows/README.md`](.github/workflows/README.md)                         |
| Nixpkgs channels (`pkgs` vs `pkgs.stable`) | `flake.nix` inputs + overlay docs inline                                             |
| Editing the Neovim config                  | [`home/base/tui/neovim/README.md`](home/base/tui/neovim/README.md)                   |
| Local helper functions (`scanPaths`, etc.) | [`lib/README.md`](lib/README.md)                                                     |
| Project tasks                              | [`todo.txt`](todo.txt) (managed with [tuxedo](https://github.com/webstonehq/tuxedo)) |

## Repo layout

```
.
├── flake.nix                    # darwin + HM + nix-on-droid outputs
├── hosts/                       # per-host system configs + bootstrap docs
│   ├── mbair/
│   └── android/pixel6/
├── modules/darwin/              # nix-darwin system modules
├── home/                        # home-manager configs
│   ├── base/                    # cross-platform core/tui/gui modules
│   │   └── tui/neovim/          # vendored nvf modules (Neovim package)
│   ├── linux|darwin|android/    # per-platform stacks
│   └── hosts/                   # per-host home entrypoints
├── lib/                         # local helper functions (vendored nix-lib)
├── secrets/                     # agenix wiring + how-to
├── vars/                        # myvars + features option schema
├── overlays/                    # pkgs.stable / unstable / nixos2511
└── pkgs/                        # custom packages
```

---

MIT License.
