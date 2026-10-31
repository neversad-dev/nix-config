# Home Manager

Three layers separate reusable configuration, platform stacks, and host choices.

```
home/
├── base/                 # Cross-platform modules
│   ├── home.nix          # User identity, stateVersion, Nix settings
│   ├── core/             # Shell, basic Git, SSH, direnv, small CLI tools
│   ├── tui/              # Workstation tools, Git extras, AI, secrets, theme
│   └── gui/              # Editors, terminals, wallpapers, fonts
├── linux/                # core.nix → tui.nix → gui.nix
├── darwin/               # Full workstation stack + AeroSpace/SketchyBar
├── android/              # Core + HM 24.05 compatibility
└── hosts/                # One entry point per host, grouped by platform
```

## Composition

Outputs reference one file under `home/hosts/`. Each host imports a platform
stack and supplies overrides. Reusable modules do not import host files.

| Host entry point           | Stack           | Integration                             |
| -------------------------- | --------------- | --------------------------------------- |
| `hosts/darwin/mbair.nix`   | `darwin`        | nix-darwin module (+ standalone output) |
| `hosts/linux/enduro.nix`   | `linux/gui.nix` | Standalone HM, generic Linux            |
| `hosts/android/pixel6.nix` | `android`       | nix-on-droid's built-in HM              |

A future Linux server can import `linux/core.nix`; HM is optional for servers,
not automatically installed by a system module. `linux/tui.nix` adds terminal
workstation tools, and `linux/gui.nix` adds desktop applications. Android uses
its own stack rather than assuming all Linux integrations work in proot.

## Defaults and feature flags

Core imports enable shell, basic Git (identity, aliases, commit template) and
SSH. The following are part of core/tui but are **opt-in and disabled by
default**: `atuin`, `direnv`, `eza`, `fastfetch`, `zoxide`, `starship`,
`neovim`, `pay-respects`, `herdr`, `btop`, `superfile`, `tuxedo` (all under
`features.cli.*`). Each host enables what it needs in its entry point, e.g.:

```nix
features.cli.starship.enable = true;
features.cli.neovim.enable = true;
```

Neovim is a Home Manager module in [`base/tui/neovim/`](base/tui/neovim/README.md)
that enables nvf with the in-repo nvf modules (no separate flake input).
It can also be run directly with `nix run github:neversad-dev/nix-config`.

`features.cli.git.enable` controls the optional Git extras (Delta, lazygit,
worktrunk); basic Git does not depend on it. Signing retains its separate flag.
Other optional features retain their existing `features.*` names. Shared
system/HM options live in `vars/features.nix`; HM-only options live in their
leaf modules. Directory `default.nix` files use `mylib.scanPaths`.

Core avoids unconditional flake-input dependencies. TUI adds Catppuccin,
agenix and AI integration; GUI adds fonts and desktop applications.

## Adding a host

1. Create `home/hosts/<platform>/<hostname>.nix` and import a platform stack.
2. Set host-specific flags and overrides there.
3. Point the standalone HM output or system HM integration at that one file.
4. Update [hosts/README.md](../hosts/README.md).

See [base/README.md](base/README.md), [android/README.md](android/README.md),
and [vars/README.md](../vars/README.md).
