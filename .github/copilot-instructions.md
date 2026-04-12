# Copilot Instructions for nix-config

## Repository Overview

This is a **public Nix configuration repository** that provides cross-platform (macOS and Linux) system configurations using nix-darwin and Home Manager. The repository is designed as a modular flake that can be used standalone or imported into other Nix flakes.

### Key Facts
- **Type**: Nix flake configuration repository
- **Size**: on the order of 60+ `.nix` files in a modular layout
- **Languages**: Nix (primary), Shell scripts, TOML configs
- **Platforms**: macOS (nix-darwin and Home Manager), Linux (Home Manager)
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
just up              # Update all flake inputs
just fmt             # Format all Nix code with alejandra
just clean           # Garbage collect old generations
```

### Direct Nix Commands (when just isn't sufficient)

```bash
# Validation (ALWAYS run before committing)
nix flake check --accept-flake-config
nix fmt . --accept-flake-config --check

# Manual builds (if just fails)
nix build .#darwinConfigurations.mbair.system
nix build .#homeConfigurations."neversad@mbair"
```

### Build Order & Dependencies

1. **ALWAYS** run `nix fmt .` before committing changes
2. **ALWAYS** run `nix flake check` to validate configuration
3. For system changes: `just darwin-build` → test → `just darwin`
4. For user changes: `just home-build` → test → `just home`

## Project Architecture

### Directory structure
```
├── flake.nix                    # Outputs: darwin/home configs, modules, packages, lib
├── Justfile
├── modules/
│   ├── darwin/                  # nix-darwin system modules
│   └── home-manager/            # Re-exported as flake `homeManagerModules` (wired in home/common)
├── home/
│   ├── common/                  # Shared HM baseline (nixpkgs, imports vars/config + homeManagerModules)
│   ├── features/
│   │   ├── cli/                 # Shell, CLI tools, tmux, yazi, etc.
│   │   ├── desktop/             # GUI apps (terminals, editors, wallpapers)
│   │   ├── darwin/              # macOS-only (aerospace, sketchybar)
│   │   ├── linux/               # Linux-only HM bits
│   │   └── development/       # Dev stacks (android, flutter, lsp, ruby, …)
│   ├── neversad/              # User entrypoints: home.nix, mbair.nix, enduro.nix
│   └── export/
│       ├── darwin/              # flake `homeModules.darwin` (consumer-facing bundle)
│       └── linux/               # flake `homeModules.linux`
├── hosts/
│   └── mbair/                   # nix-darwin: default.nix + shared options config.nix
├── vars/
│   └── config.nix               # Shared option definitions (development.*, gaming, stay-awake)
└── lib/                         # Via `nix-lib` input (mylib + relativeToRoot)
```

### Key configuration files

- **`flake.nix`**: Main entry point; `homeModules.darwin` / `homeModules.linux` point at `home/export/{darwin,linux}/`
- **`home/neversad/home.nix`**: Default username (`neversad`), `home.stateVersion`, baseline `home.packages` / session vars
- **`home/neversad/mbair.nix`** / **`enduro.nix`**: Per-host HM imports (features + optional `hosts/<host>/config.nix` via `mylib.relativeToRoot`)
- **`hosts/mbair/config.nix`**: Shared feature flags for both nix-darwin and HM on that machine
- **`vars/config.nix`**: Option schema for `development.*`, `gaming.enable`, `stay-awake.enable`
- **`.gitignore`**: Build artifacts, store paths, editor noise

### Modular Design

The configuration is designed for reuse:
- **Export modules**: `darwinModules.default`, `homeModules.{darwin,linux}`, `homeManagerModules`
- **Export utilities**: `lib` (from `nix-lib` + `relativeToRoot`)
- **Example configs**: `darwinConfigurations.mbair`, `homeConfigurations."neversad@mbair"`, `homeConfigurations."neversad@enduro"`

## Common Issues & Workarounds

### Known warnings (safe to ignore)
- Multiple `Using lib.generators.toPlist without escape = true is deprecated` — from nix-darwin, harmless
- Cachix substituter warnings on untrusted systems - Expected behavior

### Environment Setup Issues
- **Trusted user required**: For cachix substituters to work properly
- **Experimental features**: Must enable `nix-command flakes` in nix.conf
- **just/nh missing**: Install via `nix profile install nixpkgs#just nixpkgs#nh`

### Build Failures
- **Always check formatting first**: Run `nix fmt .` before debugging
- **Flake lock issues**: Run `just up` to update inputs

## Development Guidelines

### Making Changes

1. **Format code**: `just fmt` (uses alejandra formatter)
2. **Validate changes**: `nix flake check --accept-flake-config`
3. **Test build**: `just darwin-build` or `just home-build`
4. **Apply carefully**: `just darwin` or `just home`

### File Modifications

- **Nix files**: Always use 2-space indentation, format with alejandra
- **Host configs**: nix-darwin under `hosts/<hostname>/`; HM entry modules under `home/neversad/<hostname>.nix`
- **System modules**: `modules/darwin/` for macOS
- **User features**: `home/features/{cli,desktop,darwin,linux,development}/`; shared HM shell in `home/common/`

### Adding New Features

1. **Check existing modules**: Prefer `home/features/` for new programs; use `home/common/` for cross-cutting HM imports
2. **Use catppuccin theme**: Consistent theming across all applications
3. **Test on both platforms**: macOS and Linux where applicable
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

**Configuration Philosophy**: Keep configurations **minimal and focused**
- Prefer package defaults over extensive customization
- Only override settings that are truly useful, recommended, or specifically requested
- Avoid over-configuring packages - maintain simplicity and maintainability

### Android Development Configuration

The Android development setup provides a complete development environment:

- **Conditional Loading**: All Android configurations use `lib.mkIf config.development.android.enable`
- **Complete SDK**: Android SDK with build tools, platform tools, NDK, and emulator
- **Pre-configured Emulators**: 
  - `MyResizable` - Resizable emulator with multiple form factors (phone, foldable, tablet, desktop)
  - `MyPixel9` - Pixel 9 device emulator with Google APIs
- **Java Development**: Zulu OpenJDK 21 automatically configured
- **Environment Setup**: Automatic configuration of `ANDROID_HOME`, `ANDROID_SDK_ROOT`, `ANDROID_NDK_ROOT`
- **SDK Synchronization**: Automatic sync between Nix-managed SDK and Android Studio location

**Android configuration files**:
- `home/features/development/android/android.nix` — main Android SDK configuration
- `home/features/development/android/java.nix` — Java environment
- `home/features/development/android/emulators/resizable.nix` — resizable emulator definitions
- `home/features/development/android/emulators/generic.nix` — additional emulator definitions

**Usage**: Enable Android development by setting `development.android.enable = true` in host configuration.

### Recent package additions

- **mitmproxy**: HTTP/HTTPS inspection CLI
  - Location: `home/features/cli/mitmproxy.nix`
  - Provides: `mitmproxy`, `mitmdump`, `mitmweb` commands
  - Usage: Traffic inspection, debugging, and testing

## Validation Pipeline

The build check workflow validates:
1. **Flake structure**: `nix flake check --all-systems`
2. **Code formatting**: `nix fmt . --check`
3. **All configurations**: Auto-discovered darwin/home configs
4. **Cross-platform**: Tests on macOS and Linux runners
5. **Package builds**: Standalone packages like nvim

### Manual Validation
```bash
# Full validation sequence
nix flake check --accept-flake-config
nix fmt . --accept-flake-config --check
just darwin-build  # or just home-build
```
