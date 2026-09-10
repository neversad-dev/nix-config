# Nix config

[![Built with Nix](https://img.shields.io/badge/Built_With-Nix-5277C3.svg?logo=nixos&labelColor=73C3D5)](https://nixos.org)
[![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=F0F0F0)](https://www.apple.com/macos)
[![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![Build Check](https://img.shields.io/github/actions/workflow/status/neversad-dev/nix-config/build-check.yml?branch=main&logo=github-actions&logoColor=white&label=build%20check)](https://github.com/neversad-dev/nix-config/actions/workflows/build-check.yml)
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
[![Catppuccin](https://img.shields.io/badge/Catppuccin-302D41?logo=catppuccin&logoColor=DDB6F2)](https://github.com/catppuccin)
[![Home Manager](https://img.shields.io/badge/Home_Manager-blue.svg?logo=nixos&logoColor=white)](https://github.com/nix-community/home-manager)

Notes to myself: nix-darwin + Home Manager flake (macOS + Linux). I can point another flake at this repo as an input if I need reuse; day-to-day I work from this tree.

## What lives here

- macOS and Linux Home Manager paths share the same `features.*` toggles where it matters.
- Catppuccin across apps, CLI/desktop/dev bundles under `home/features/`.
- Primary username and related identity bits come from `myvars` (`import ./vars` in `flake.nix`).

## Builds and switches

All development tooling (`nh`, `just`, `nom`, `alejandra`, etc.) is provided by the `devShell` defined in `flake.nix`. 
Because `direnv` and `nix-direnv` are configured, simply `cd` into this repository to automatically activate the environment.

Then you can use `just` to build and switch:

```bash
just darwin  # build and switch macOS (via nh)
just home    # build and switch Home Manager (via nh)
just up      # update flake inputs
just         # list all commands
```

*(Manual fallback if direnv is disabled: run `nix develop` first to get access to `nh` and `just`, or use raw `nix build ...` commands).*

## Reusing this flake elsewhere

Only when I need it — import `github:neversad-dev/nix-config` (or a path), then `darwinModules.default` / `homeModules.darwin` or `homeModules.linux` from the flake outputs.

## My hosts (mental map)

- **`mbair`** — `hosts/mbair/` + HM `flake.nix` output `"<primaryUser>@mbair"` → `home/<primaryUser>/mbair.nix`.
- **`enduro`** — Linux HM only: `"<primaryUser>@enduro"` → `home/<primaryUser>/enduro.nix`.

`<primaryUser>` is always `myvars.primaryUser` from `vars/default.nix`.

## `features.*` cheat sheet

Defaults and real wiring live in `vars/features.nix` and each host’s `hosts/<hostname>/features.nix`. Rough list:

- `features.development.cursor.enable`
- `features.development.vscode.enable`
- `features.development.android.enable`
- `features.gaming.enable`
- `features.stayAwake.enable`

How to wire shared `features.nix` into both stacks and how to add new options: [vars/README.md](vars/README.md).

## Android stack reminder

With `features.development.android.enable`, I get SDK bits, env vars (`ANDROID_*`), emulators I defined (e.g. resizable / Pixel profile names in the modules), and Java alignment — details drift in code; grep `android` under `home/features/development/` when I change machines.

## Repo layout (where I put things)

- **`flake.nix`** — outputs: darwin + HM configs, `darwinModules`, `homeModules.{darwin,linux}`, packages, `lib`, exported `myvars`.
- **`modules/darwin/`** — system modules I stack on darwin hosts.
- **`hosts/<hostname>/`** — `default.nix` + shared `features.nix` for that machine.
- **`secrets/`** — ragenix/agenix wiring; [secrets/README.md](secrets/README.md).
- **`home/common/`** — HM baseline (imports `vars/features.nix` for options).
- **`home/features/`** — `cli/`, `desktop/`, `darwin/`, `linux/`, `development/`.
- **`home/<username>/`** — per-user entrypoints (`home.nix`, host-specific imports).
- **`home/export/{darwin,linux}/`** — what the flake exposes as `homeModules.*`.
- **`vars/`** — `myvars` + `features` option schema; [vars/README.md](vars/README.md).
- **`lib/`** — helpers via `nix-lib` input.

CI behavior when I forget: [.github/workflows/README.md](.github/workflows/README.md).

---

MIT License.
