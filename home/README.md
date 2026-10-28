# Home Manager

This directory contains all Home Manager configurations organized by platform and functionality.

## Structure

```
home/
├── common/              # Shared baseline for all HM outputs
│   ├── default.nix      # Imports secrets + features options
│   └── secrets.nix      # User-level agenix identity path
├── core/                # Always-on essentials (future: no feature flags)
│   ├── shell.nix        # zsh/bash, PATH, aliases
│   ├── git.nix          # git config (basic, not full git/ stack)
│   ├── ssh.nix          # ~/.ssh/config
│   └── ...
├── features/            # Togglable extras (opt-in per host)
│   ├── ai/              # Pi coding agent, atuin, etc.
│   ├── cli/             # Neovim, starship, btop, fzf, ...
│   ├── darwin/          # macOS-specific apps (aerospace, sketchybar)
│   ├── desktop/         # Ghostty, Kitty, VS Code/Cursor, Zed
│   ├── development/     # Android SDK, language toolchains
│   └── linux/           # Linux-specific apps
├── neversad/            # Per-user entrypoints
│   ├── home.nix         # Shared user settings (stateVersion, etc.)
│   ├── fonts.nix        # Font packages
│   ├── mbair.nix        # macOS host entrypoint
│   └── enduro.nix       # Linux host entrypoint
└── README.md            # This file
```

## How features work

Options are declared **decentrally** — each leaf module under `home/features/` (or `vars/features.nix` for cross-cutting ones) exposes its own toggle. Parent `default.nix` files import the whole directory via `mylib.scanPaths` but do not gate anything themselves.

### Two kinds of toggles

| Kind | Where declared | What it controls |
|---|---|---|
| **Cross-cutting** | `vars/features.nix` | Both darwin and HM (e.g. `features.gaming`, `features.stayAwake`, `features.development.vscode`) |
| **HM-only** | In the leaf module itself (e.g. `home/features/cli/neovim.nix`) | Only Home Manager (e.g. `features.cli.neovim`, `features.desktop.zed`) |

Leaf modules gate themselves with `lib.mkIf config.features.<path>.enable`:

```nix
# home/features/cli/neovim.nix
{ config, lib, ... }:
{
  options.features.cli.neovim.enable = lib.mkEnableOption "Neovim";
  config = lib.mkIf config.features.cli.neovim.enable {
    programs.neovim.enable = true;
  };
}
```

### Always-on vs. opt-in

Not everything has a toggle. Small utilities that are harmless when idle (`eza`, `zoxide`, `bat`, `fzf`, ...) are imported unconditionally by their parent `default.nix` and are always present. This is fine — they only activate when you invoke them.

Toggles are reserved for:
- Heavy or opinionated tools (neovim, desktop editors, window managers)
- Things that change system behavior (SSH commit signing, mitmproxy)
- Platform-specific apps (aerospace, sketchybar)
- Anything you might want to disable on a headless server or VPS

### Future: `home/core/`

The current `home/common/` is light (just agenix wiring). A future `home/core/` directory is planned for true essentials you want on *every* machine — even a fresh VPS — without thinking about feature flags: shell baseline, git auth config, SSH client settings, direnv, coreutils. See `todo.txt` for the tracking task.

### Setting toggles per host

```nix
# home/neversad/mbair.nix
{
  features = {
    ai.enable = true;
    cli = {
      neovim.enable = true;
      git.enable = true;
      git.signing.enable = true;
      starship.enable = true;
    };
    desktop = {
      ghostty.enable = true;
      zed.enable = true;
    };
  };
}
```

Enable a feature for one host, disable for another, without forking the module code.

## Adding a new Home Manager host

1. Add `home/<user>/<hostname>.nix` importing the right `../features/*` stacks
2. Add `homeConfigurations."<user>@<hostname>"` in `flake.nix`
3. Wire `hosts/<hostname>/features.nix` if you need host-specific feature flags shared with darwin

See [`vars/README.md`](../vars/README.md) for cross-cutting options.
