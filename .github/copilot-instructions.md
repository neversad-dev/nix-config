# Copilot Instructions for nix-config

## Repository Overview

This is a **public Nix configuration repository** that provides cross-platform (macOS, Linux and Android) configurations using nix-darwin, Home Manager and nix-on-droid. The repository is designed as a modular flake that can be used standalone or imported into other Nix flakes.

### Key Facts

- **Type**: Nix flake configuration repository
- **Size**: on the order of 60+ `.nix` files in a modular layout
- **Languages**: Nix (primary), Shell scripts, TOML configs
- **Platforms**: macOS (nix-darwin + embedded Home Manager), Linux (standalone Home Manager), Android (nix-on-droid, pinned to 24.05)
- **Theme**: Catppuccin Mocha throughout all applications
- **License**: MIT

## Build System & Commands

### Prerequisites

- **Nix version**: 2.28.3+ with experimental features (`nix-command flakes`)
- **Required tools**: `just` (command runner), `nh` (nix helper)
- **macOS**: nix-darwin for system-level changes and Home Manager for user-level configurations
- **Linux**: Home Manager for user-level configurations

### Essential Commands (via just)

**ALWAYS use `just` commands instead of raw nix commands when available:**

```bash
just                 # List all available commands
just darwin-build    # Build macOS system (safe, no activation)
just darwin          # Build and activate macOS system
just home-build      # Build Home Manager config (safe, no activation)
just home            # Build and activate Home Manager config
just droid           # nix-on-droid switch (on-device only)
just up              # Update all flake inputs
just fmt             # Format code (Nix, Markdown/YAML, Shell, TOML)
just clean           # Garbage collect old generations
```

### Direct Nix Commands (when just isn't sufficient)

```bash
# Validation (ALWAYS run before committing)
nix flake check --accept-flake-config
just fmt-check

# Manual builds (if just fails)
nix build .#darwinConfigurations.mbair.system
nix build .#homeConfigurations."neversad@mbair"
nix eval --raw .#nixOnDroidConfigurations.pixel6.config.home-manager.config.home.activationPackage.drvPath
```

### Build Order & Dependencies

1. **ALWAYS** run `just fmt` before committing changes
2. **ALWAYS** run `nix flake check` to validate configuration
3. For system changes: `just darwin-build` → test → `just darwin`
4. For user changes: `just home-build` → test → `just home`

## Project Architecture

### Directory structure

```
├── flake.nix                    # Outputs: darwin/home/nix-on-droid configs, nvim package
├── Justfile
├── modules/
│   ├── darwin/                  # nix-darwin system modules
│   └── common/                  # Shared nix-darwin bits (imports vars/features.nix)
├── home/
│   ├── base/
│   │   ├── home.nix             # User identity, stateVersion, Nix settings (imports vars/features.nix)
│   │   ├── core/                # Shell, basic git, SSH, direnv, small CLI tools
│   │   ├── tui/                 # Git extras, neovim (nvf), AI, secrets, catppuccin, TUIs
│   │   └── gui/                 # Editors, terminals, wallpapers, fonts
│   ├── darwin/                  # macOS stack (aerospace, sketchybar)
│   ├── linux/                   # core.nix → tui.nix → gui.nix
│   ├── android/                 # nix-on-droid stack + HM 24.05 compat.nix
│   └── hosts/<platform>/        # One HM entry point per host
├── hosts/
│   ├── mbair/                   # nix-darwin host (embeds HM), features.nix
│   └── android/pixel6/          # nix-on-droid system layer
├── overlays/                    # pkgs.stable / unstable / nixos2511, android-packages
├── pkgs/                        # Custom + vendored packages
├── vars/
│   └── features.nix             # Shared option definitions (features.*)
└── lib/                         # Local helpers (mylib: scanPaths, mkEditableConfig, relativeToRoot)
```

### Key configuration files

- **`flake.nix`**: Main entry point; all host outputs, `packages.<system>.{default,nvim}`
- **`home/base/home.nix`**: Default username (`neversad`), `home.stateVersion`, baseline packages / session vars
- **`home/hosts/<platform>/<host>.nix`**: Per-host HM entry point (imports a platform stack, sets `features.*`)
- **`hosts/mbair/features.nix`**: Shared feature flags for both nix-darwin and HM on that machine
- **`home/android/compat.nix`**: Polyfills for options newer than HM 24.05 (shared modules must evaluate there)
- **`vars/features.nix`**: Option schema for `features.*` (darwin + Home Manager)
- **`.gitignore`**: Build artifacts, store paths, editor noise

### Outputs

- **Configs**: `darwinConfigurations.mbair`, `homeConfigurations."neversad@mbair"` (HM-only iteration), `homeConfigurations."neversad@enduro"`, `nixOnDroidConfigurations.pixel6`
- **Packages**: `packages.<system>.nvim` (also `default`): the configured Neovim
- **Utilities**: `mylib` from `./lib` + `relativeToRoot` (internal, passed as a module arg)

## Common Issues & Workarounds

### Known warnings (safe to ignore)

- Multiple `Using lib.generators.toPlist without escape = true is deprecated` — from nix-darwin, harmless
- Cachix substituter warnings on untrusted systems - Expected behavior

### Environment Setup Issues

- **Trusted user required**: For cachix substituters to work properly
- **Experimental features**: Must enable `nix-command flakes` in nix.conf
- **just/nh missing**: Install via `nix profile install nixpkgs#just nixpkgs#nh`

### Build Failures

- **Always check formatting first**: Run `just fmt` before debugging
- **Flake lock issues**: Run `just up` to update inputs

## Development Guidelines

### Making Changes

1. **Format code**: `just fmt` (uses alejandra, prettier, shfmt, taplo formatters)
2. **Validate changes**: `nix flake check --accept-flake-config`
3. **Test build**: `just darwin-build` or `just home-build`
4. **Apply carefully**: `just darwin` or `just home`

### File Modifications

- **Nix files**: Always use 2-space indentation, format with alejandra (format all code via `just fmt`)
- **Host configs**: system under `hosts/<hostname>/`; HM entry modules under `home/hosts/<platform>/<hostname>.nix`
- **System modules**: `modules/darwin/` for macOS
- **User modules**: `home/base/{core,tui,gui}/`; platform-only bits in `home/{darwin,linux,android}/`

### Adding New Features

1. **Check existing modules**: Put new programs in `home/base/{core,tui,gui}/` behind a `features.*` flag; options newer than HM 24.05 need a polyfill in `home/android/compat.nix`
2. **Use catppuccin theme**: Consistent theming across all applications
3. **Test on all platforms**: macOS, Linux and Android where applicable (Android: no unstable TUI binaries, glibc >= 2.42 breaks ttys; use `pkgs.nixos2511`)
4. **Update example hosts**: Add to appropriate host configs

### Package Installation Guidelines (macOS)

For macOS hosts, follow this package installation priority:

1. **UI Applications**: **ALWAYS prefer Homebrew** via `modules/darwin/homebrew.nix`
   - GUI apps, IDEs, browsers, media players
   - Better integration with macOS (app bundles, system integration)
   - Example: VS Code, Chrome, Parallels, Android Studio
   - **Fallback**: If Homebrew installation is not possible/unreliable, use Mac App Store via `homebrew.masApps`
   - MAS Example: `Bitwarden = 1352778147; PDFgear = 6469021132; Amphetamine = 937984704;`

2. **Command-line Tools**: **Try Nix first**, fallback to Homebrew
   - First attempt: Install via Nix packages in `home/` modules
   - If unsupported/broken on Darwin: Add to `homebrew.brews` in `homebrew.nix`
   - Example: Development tools, CLI utilities, system tools

3. **System-level Changes**: Use nix-darwin in `modules/darwin/`
   - System preferences, services
   - macOS-specific configuration that requires root/system access

### Package Configuration Guidelines (All Platforms)

When adding any package/program, follow this configuration priority:

1. **Home Manager Programs Module** (PREFERRED)
   - Use `programs.<package>.enable = true` with available properties
   - Provides declarative configuration with type checking
   - Example: `programs.git.enable`, `programs.starship.enable`, `programs.tmux.enable`
   - Check Home Manager options: `man home-configuration.nix` or online docs

2. **Fallback: Package + Config File**
   - Install via Nix packages: `home.packages = [ pkgs.<package> ];`
   - Add configuration via Home Manager file management
   - Use package's default config location and native format
   - Example: `xdg.configFile."app/config.toml".text = "...";`
   - Example: `home.file.".config/app/config.json".source = ./config.json;`

3. **Stable package fallback**
   - The default nixpkgs is `nixos-unstable`; if a package is broken or behaves badly, pin it via the `stable` overlay:
   - `pkgs.stable.<package>` pulls from `nixos-26.05`
   - Example: `home.packages = [ pkgs.stable.some-package ];`

**Configuration Philosophy**: Keep configurations **minimal and focused**

- Prefer package defaults over extensive customization
- Only override settings that are truly useful, recommended, or specifically requested
- Avoid over-configuring packages - maintain simplicity and maintainability

### Android Development

`features.development.android.enable` installs Android Studio via Homebrew (`modules/darwin/homebrew.nix`).

### Recent package additions

- **mitmproxy**: HTTP/HTTPS inspection CLI
  - Location: `home/base/tui/mitmproxy.nix`
  - Provides: `mitmproxy`, `mitmdump`, `mitmweb` commands
  - Usage: Traffic inspection, debugging, and testing

## Validation Pipeline

The build check workflow validates:

1. **Flake structure**: `nix flake check --all-systems`
2. **Code formatting**: `just fmt-check` (or `nix develop --command just fmt-check`)
3. **All configurations**: Auto-discovered darwin/home configs
4. **Cross-platform**: Tests on macOS and Linux runners
5. **Package builds**: Standalone packages like nvim
6. **nix-on-droid**: evaluated only (HM generation), not built

### Manual Validation

```bash
# Full validation sequence
nix flake check --accept-flake-config
just fmt-check
just darwin-build  # or just home-build
```
