# Home Manager

Home configuration has three layers: reusable modules, platform stacks, and per-host choices. Home Manager is integrated into nix-darwin on macOS and nix-on-droid on Android; there are no standalone Home Manager hosts.

```text
home/
├── base/
│   ├── home.nix          # Identity, stateVersion, editor fallback, Nix settings
│   ├── core/             # Shell, Git, SSH, and lightweight CLI integrations
│   ├── tui/              # Terminal tools, Neovim, AI, and theming
│   └── gui/              # Editors, terminals, wallpapers, and fonts
├── darwin/               # Full workstation stack and macOS integrations
├── linux/                # Core/TUI/GUI stacks for future NixOS hosts
├── android/              # Core + TUI with HM 24.05 compatibility
└── hosts/                # One home entry point per host, grouped by platform
```

## Composition

Each system's Home Manager integration points to one file under `home/hosts/`. That file imports a platform stack and sets host-specific flags and overrides. Reusable modules never import host files.

| Home entry point           | Platform stack | Integration                |
| -------------------------- | -------------- | -------------------------- |
| `hosts/darwin/mbair.nix`   | `darwin/`      | nix-darwin module          |
| `hosts/android/pixel6.nix` | `android/`     | nix-on-droid's built-in HM |

Paths in this table are relative to `home/`.

- **Darwin** imports shared identity, core, TUI, GUI, and macOS-only modules.
- **Android** imports shared identity, core, and TUI with compatibility shims; GUI modules are excluded.
- **Linux** offers layered core/TUI/GUI stacks, but no current flake host uses them.

Directory `default.nix` modules commonly use `mylib.scanPaths` to discover child modules. Importing a module makes its options available; it does not necessarily enable the program.

## Defaults and feature flags

`base/home.nix` supplies default identity and home-directory values, a fallback Vim editor, Nix settings, and a compatibility `home.stateVersion`. The state version is not the installed Home Manager release; Android explicitly uses `24.05`.

The core stack provides shell, SSH, Git, and GitHub CLI integration. Optional programs such as Atuin, direnv, Starship, Neovim, and the TUI tools are gated by disabled-by-default `features.cli.*` flags. Enable only what the host needs:

```nix
features.cli.starship.enable = true;
features.cli.neovim.enable = true;
```

Git has separate controls:

- The Git binary is available regardless of the feature flags.
- `features.cli.git.core.enable` enables identity, ignores, aliases, and the commit template.
- `features.cli.git.extended.enable` enables Delta, lazygit, and worktrunk.
- `features.cli.git.signing.enable` enables SSH commit signing only when `features.cli.git.extended.enable` is also enabled.

Shared system/HM options are declared in [`vars/features.nix`](../vars/features.nix). Home Manager-only options are declared in their owning modules. On Darwin, shared flags can be imported from `hosts/<host>/features.nix` by both module trees; HM-only flags belong in the home entry point. See the [feature guide](../vars/README.md).

## Compatibility and secrets

Android runs HM 24.05. Newer shared options need a shim in [`android/compat.nix`](android/compat.nix), or a guard when the integration cannot be supported. Modules such as Catppuccin's HM integration and pi skip their newer upstream modules when `isHm24` is set. Shared styling and program configuration may still apply.

On Darwin, agenix decrypts secrets at the **system** level. Home Manager consumers use `osConfig.age.secrets` to reference runtime paths, never plaintext values in Nix expressions. Android currently has no managed secrets. See [secrets](../secrets/README.md).

## Adding a module or host

To add a program, place it in the appropriate `base/core`, `base/tui`, or `base/gui` layer; use a platform directory for platform-only integrations. Prefer an existing Home Manager program module and opt-in flags over unconditional packages.

To add a host:

1. Create `home/hosts/<platform>/<hostname>.nix` and import a platform stack.
2. Set host-specific flags and overrides there.
3. Point the system's Home Manager integration at that file.
4. Update the [host documentation](../hosts/README.md) and root host table.

## Further reading

- [Shared layers](base/README.md)
- [Darwin stack](darwin/README.md)
- [Android stack](android/README.md)
- [Future Linux stacks](linux/README.md)
- [Neovim and CodeCompanion](base/tui/neovim/README.md)
