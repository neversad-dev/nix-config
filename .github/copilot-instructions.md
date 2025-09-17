# Copilot Instructions for nix-config

## Repository Overview

This is a **public Nix configuration repository** that provides cross-platform (macOS and Linux) system configurations using nix-darwin and Home Manager. The repository is designed as a modular flake that can be used standalone or imported into other Nix flakes.

### Key Facts
- **Type**: Nix flake configuration repository
- **Size**: ~54 Nix files across modular structure
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

### Directory Structure
```
├── flake.nix                 # Main flake configuration
├── Justfile                  # Command runner (like Makefile)
├── modules/
│   ├── darwin/              # macOS system modules
│   └── common/              # Shared system modules
├── home/
│   ├── darwin/              # macOS user configs
│   ├── linux/               # Linux user configs
│   └── common/              # Shared user configs
├── hosts/                   # Host configurations
│   ├── mbair/              # MacBook Air config
│   ├── enduro/             # Linux laptop
│   └── tinkerdell/         # Linux laptop
├── lib/                     # Custom library functions
└── vars/                    # Variables and constants
```

### Key Configuration Files

- **`flake.nix`**: Main entry point, defines all outputs and configurations
- **`vars/default.nix`**: User variables (username: "neversad", email, etc.)
- **`lib/default.nix`**: Custom helper functions, including `mkEditableConfig`
- **`.gitignore`**: Excludes build artifacts, Nix store items, editor files

### Modular Design

The configuration is designed for reuse:
- **Export modules**: `darwinModules.default`, `homeModules.{darwin,linux}`
- **Export utilities**: `lib` and `vars` for other flakes
- **Example configs**: Ready-to-use host configurations

## Continuous Integration

### GitHub Actions Workflows

1. **Build Check** (`.github/workflows/build-check.yml`)
   - Triggers on push/PR to main branch
   - Auto-discovers all configurations from flake
   - Tests on both macOS (macos-latest) and Linux (ubuntu-latest)
   - Validates formatting with `nix fmt . --check`
   - Performs dry-run builds of all configurations

2. **Update Dependencies** (`.github/workflows/update-dependencies.yml`)
   - Scheduled weekly (Sundays 2 AM UTC)
   - Updates flake inputs with `nix flake update`
   - Creates PRs automatically
   - Validates updates with `nix flake check`

### CI Requirements
- **No secrets needed** beyond default `GITHUB_TOKEN`
- **Caching**: Uses Cachix (nix-community) and Magic Nix Cache
- **Multi-arch**: Tests aarch64-darwin, x86_64-linux, aarch64-linux

## Common Issues & Workarounds

### Known Warnings (Safe to Ignore)
- `warning: unknown flake output 'vars'` - Expected, vars are exported for reuse
- Multiple `Using lib.generators.toPlist without escape = true is deprecated` - From nix-darwin, harmless
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
- **Host configs**: Located in `hosts/` directory, organized by hostname
- **Shared modules**: Use `modules/common/` for cross-platform code
- **User configs**: Platform-specific in `home/{darwin,linux}/`

### Adding New Features

1. **Check existing modules**: Look in `home/common/` first
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
