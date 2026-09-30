# Nix config

[![Built with Nix](https://img.shields.io/badge/Built_With-Nix-5277C3.svg?logo=nixos&labelColor=73C3D5)](https://nixos.org)
[![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=F0F0F0)](https://www.apple.com/macos)
[![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![Build Check](https://img.shields.io/github/actions/workflow/status/neversad-dev/nix-config/build-check.yml?branch=main&logo=github-actions&logoColor=white&label=build%20check)](https://github.com/neversad-dev/nix-config/actions/workflows/build-check.yml)
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
[![Catppuccin](https://img.shields.io/badge/Catppuccin-302D41?logo=catppuccin&logoColor=DDB6F2)](https://github.com/catppuccin)
[![Home Manager](https://img.shields.io/badge/Home_Manager-blue.svg?logo=nixos&logoColor=white)](https://github.com/nix-community/home-manager)

Notes to myself: nix-darwin + Home Manager flake (macOS + Linux). Day-to-day I work from this tree.

## What lives here

- macOS and Linux Home Manager paths share the same `features.*` toggles where it matters.
- Catppuccin across apps, CLI/desktop/dev bundles under `home/features/`.
- Primary username and related identity bits come from `myvars` (`import ./vars` in `flake.nix`).

## Builds and switches

All development tooling (`nh`, `just`, `alejandra`, `prettier`, `shfmt`, `taplo`, `tuxedo`, etc.) is provided by the `devShell` defined in `flake.nix`.
Because `direnv` and `nix-direnv` are configured, simply `cd` into this repository to automatically activate the environment.

Then you can use `just` to build and switch:

```bash
just darwin  # build and switch macOS (via nh)
just home    # build and switch Home Manager (via nh)
just up      # update flake inputs
just         # list all commands
```

_(Manual fallback if direnv is disabled: run `nix develop` first to get access to `nh` and `just`, or use raw `nix build ...` commands)._

## My hosts (mental map)

- **`mbair`** — `hosts/mbair/` + HM `flake.nix` output `"<primaryUser>@mbair"` → `home/<primaryUser>/mbair.nix`.
- **`enduro`** — Linux HM only: `"<primaryUser>@enduro"` → `home/<primaryUser>/enduro.nix`.

`<primaryUser>` is always `myvars.primaryUser` from `vars/default.nix`.

## Project task management (tuxedo)

This repo uses a `todo.txt` file for project tasks instead of GitHub issues. [tuxedo](https://github.com/webstonehq/tuxedo) (a fast terminal UI for todo.txt) is included in the dev shell, and `just` commands wrap the most common operations:

```bash
just todo           # open project todo.txt in tuxedo TUI
just todo-add "..." # add a task (supports natural language)
just todo-ls        # list tasks
just todo-done 3    # mark task #3 complete
just todo-archive   # move done tasks to done.txt
```

Personal tasks live under `~/.todo` via the tuxedo home-manager feature (`home/features/cli/tuxedo/`).

### todo.txt conventions in this repo

Since `todo.txt` lives inside the repo, we don't use `+nix-config` as a project. Instead:

- **`+project`** — names the specific tool, program, or subsystem being worked on (e.g., `+aerospace`, `+pass`, `+yubikey`, `+nixpkgs`)
- **`@tag`** — marks cross-cutting category or type of work (e.g., `@security` for auth/secrets/keys, `@refactor` for structural changes)

This keeps filtering useful: `just todo-ls +aerospace` for aerospace items, `just todo-ls @security` for all security work.

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

- **`flake.nix`** — outputs: darwin + HM configs, devShells, formatter.
- **`modules/darwin/`** — system modules I stack on darwin hosts.
- **`hosts/<hostname>/`** — `default.nix` + shared `features.nix` for that machine.
- **`secrets/`** — ragenix/agenix wiring; [secrets/README.md](secrets/README.md).
- **`home/common/`** — HM baseline (imports `vars/features.nix` for options).
- **`home/features/`** — `cli/`, `desktop/`, `darwin/`, `linux/`, `development/`.
- **`home/<username>/`** — per-user entrypoints (`home.nix`, host-specific imports).
- **`vars/`** — `myvars` + `features` option schema; [vars/README.md](vars/README.md).
- **`lib/`** — helpers via `nix-lib` input.

CI behavior when I forget: [.github/workflows/README.md](.github/workflows/README.md).

---

MIT License.
