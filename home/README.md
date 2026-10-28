# Home Manager

This directory contains all Home Manager configurations organized by platform and functionality.

## Structure

```
home/
├── common/              # Shared baseline for all HM outputs
│   ├── default.nix      # Imports secrets + features options
│   └── secrets.nix      # User-level agenix identity path
├── features/            # Togglable bundles
│   ├── ai/              # Pi coding agent, atuin, etc.
│   ├── cli/             # Shells, git, tmux, tools, ...
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

Each bundle under `home/features/` uses `lib.mkIf config.features.<path>.enable` to gate its contents. The `features.*` schema lives in [`vars/features.nix`](../vars/features.nix) and is imported by both darwin and HM.

Example — `mbair.nix`:

```nix
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

See [`vars/README.md`](../vars/README.md) for how `features.nix` is declared and wired.
