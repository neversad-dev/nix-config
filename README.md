# Nix Configuration

[![Built with Nix](https://img.shields.io/badge/Built_With-Nix-5277C3.svg?logo=nixos&labelColor=73C3D5)](https://nixos.org)
[![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=F0F0F0)](https://www.apple.com/macos)
[![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![Build Check](https://img.shields.io/github/actions/workflow/status/neversad-dev/nix-config/build-check.yml?branch=main&logo=github-actions&logoColor=white&label=build%20check)](https://github.com/neversad-dev/nix-config/actions/workflows/build-check.yml)
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
[![Catppuccin](https://img.shields.io/badge/Catppuccin-302D41?logo=catppuccin&logoColor=DDB6F2)](https://github.com/catppuccin)
[![Home Manager](https://img.shields.io/badge/Home_Manager-blue.svg?logo=nixos&logoColor=white)](https://github.com/nix-community/home-manager)

Public nix-darwin and home-manager configuration that can be used standalone or imported into other flakes.

## Features

- **Cross-platform**: macOS (nix-darwin) and Linux support
- **Modular**: Mix-and-match modules 
- **Modern**: Latest Nix flakes and best practices
- **Catppuccin themed**: Consistent theming across applications
- **Development ready**: Includes Neovim configuration and dev tools

## Quick Start

### Standalone Usage

```bash
git clone https://github.com/neversad-dev/nix-config.git
cd nix-config

# macOS
nix build .#darwinConfigurations.mbair.system
sudo ./result/sw/bin/darwin-rebuild switch --flake .

# Linux Home Manager (see flake.nix for configured names, e.g. neversad@enduro)
nix build '.#homeConfigurations."neversad@enduro"'
./result/activate
```

### As Flake Input

```nix
{
  inputs.nix-config.url = "github:neversad-dev/nix-config";
  
  outputs = { nix-config, ... }: {
    darwinConfigurations.myhost = nix-darwin.lib.darwinSystem {
      modules = [ nix-config.darwinModules.default ];
    };
    
    homeConfigurations."user@host" = home-manager.lib.homeManagerConfiguration {
      # Use `homeModules.darwin` on macOS or `homeModules.linux` on Linux
      modules = [ nix-config.homeModules.linux ];
    };
  };
}
```

## Essential Commands (with just)

```bash
just            # List all commands
just build      # Build the system
just switch     # Apply configuration  
just update     # Update flake inputs
just gc         # Garbage collect
```

## Example hosts

- **`mbair`** — nix-darwin system config under `hosts/mbair/` and matching Home Manager config `neversad@mbair` in `flake.nix`
- **`enduro`** — Linux Home Manager config `neversad@enduro` in `flake.nix` (entry module `home/neversad/enduro.nix`)

## Configuration Options

- `development.cursor.enable` - Enable Cursor editor configurations (default: false)
- `development.vscode.enable` - Enable VSCode editor configurations (default: false)
- `development.android.enable` - Enable Android development configurations (default: false)
- `development.flutter.enable` - Enable Flutter configurations (default: false)
- `development.ruby.enable` - Enable Ruby configurations (default: false)
- `gaming.enable` - Enable gaming-related packages (default: false)
- `stay-awake.enable` - Enable stay-awake configurations (default: false)

### Usage examples

**Recommended: shared host options**

Define feature flags once in `hosts/<hostname>/config.nix`, then wire that file into both nix-darwin and Home Manager so system and user config stay aligned.

```nix
# hosts/myhost/config.nix — shared options (imported by darwin + HM)
{
  development.cursor.enable = true;
  development.vscode.enable = false;
  development.android.enable = false;
  gaming.enable = false;
}

# hosts/myhost/default.nix — nix-darwin
{
  imports = [ ./config.nix ];
  # ... users, networking, system.stateVersion, etc.
}

# home/neversad/myhost.nix — Home Manager entry (see home/neversad/mbair.nix)
{ mylib, ... }: {
  imports = [
    (mylib.relativeToRoot "hosts/myhost/config.nix")
    ./home.nix
    ../common
    ../features/cli
    ../features/desktop
    ../features/darwin # or ../features/linux on Linux
    ../features/development
  ];
}
```

Add a matching `homeConfigurations."user@myhost"` in `flake.nix` that lists `home/neversad/myhost.nix` (and any extra modules, e.g. Neovim from `nvf-config`).

### Adding New Options

1. **Define the option** in `vars/features.nix`:
```nix
myFeature.enable = lib.mkOption {
  type = lib.types.bool;
  default = false;
  description = "Enable My Feature";
};
```

2. **Use the option** in modules:
```nix
config = lib.mkIf config.myFeature.enable {
  # Your configuration here
};
```

3. **Set the option** in shared host config and keep darwin/HM imports in sync (see usage examples above).

**Rules:**
- Always use `lib.mkIf` for conditional configurations
- Follow the `featureName.enable` naming convention
- Document options with clear descriptions
- Set sensible defaults (usually `false` for optional features)

### Android development features

When `development.android.enable = true`, the configuration provides:

- **Complete Android SDK**: Build tools, platform tools, NDK, and emulator
- **Pre-configured Emulators**: 
  - `MyResizable` - Resizable emulator with multiple form factors
  - `MyPixel9` - Pixel 9 device emulator with Google APIs
- **Java Development**: Zulu OpenJDK 21 automatically configured
- **Environment Variables**: `ANDROID_HOME`, `ANDROID_SDK_ROOT`, `ANDROID_NDK_ROOT`
- **SDK Synchronization**: Automatic sync with Android Studio location

## Repository layout

- **`flake.nix`** — Outputs: `darwinConfigurations`, `homeConfigurations`, `darwinModules`, `homeModules.{darwin,linux}`, `packages`, `lib`
- **`modules/darwin/`** — nix-darwin system modules
- **`hosts/<hostname>/`** — Per-machine nix-darwin config (`default.nix`) and shared options (`config.nix`)
- **`home/common/`** — Shared Home Manager baseline (nixpkgs, imports `vars/features.nix`)
- **`home/features/`** — Feature bundles: `cli/`, `desktop/`, `darwin/`, `linux/`, `development/`
- **`home/neversad/`** — User-specific entrypoints (`home.nix`, `mbair.nix`, `enduro.nix`, …)
- **`home/export/{darwin,linux}/`** — Flake `homeModules.darwin` / `homeModules.linux` for consumers (re-export layout; see `flake.nix`)
- **`vars/features.nix`** — Shared `options` for `features.*` (nix-darwin + Home Manager)
- **`lib/`** — Custom library helpers (via `nix-lib` input)

---

MIT License - Open source configuration for the Nix community.