# Nix Configuration

This is my public nix-darwin and home-manager configuration that can be used as a standalone setup or imported into other flakes.

## Features

- **Cross-platform**: Supports both macOS (nix-darwin) and Linux systems
- **Modular**: Well-organized modules that can be mixed and matched
- **Modern**: Uses latest Nix flakes and follows best practices
- **Themes**: Catppuccin theme integration across all applications
- **Development Ready**: Includes Neovim configuration and development tools

## Quick Start

### Standalone Usage

1. Clone this repository:
```bash
git clone https://github.com/neversad-dev/nix-config.git
cd nix-config
```

2. Build for your system:
```bash
# For macOS
nix build .#darwinConfigurations.mbair.system

# For Linux Home Manager
nix build .#homeConfigurations."${USER}@linux-vm"
```

3. Apply the configuration:
```bash
# For macOS
sudo ./result/sw/bin/darwin-rebuild switch --flake .

# For Linux Home Manager
./result/activate
```

### As a Flake Input

Add this to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-config.url = "github:neversad-dev/nix-config";
  };

  outputs = { nixpkgs, nix-config, ... }: {
    # Use the modules
    darwinConfigurations.myhost = nix-darwin.lib.darwinSystem {
      modules = [
        nix-config.darwinModules.default
        # your configuration
      ];
    };

    homeConfigurations."user@host" = home-manager.lib.homeManagerConfiguration {
      modules = [
        nix-config.homeModules.default
        # your configuration
      ];
    };
  };
}
```

## Structure

- `modules/` - System-level modules for nix-darwin
- `home/` - Home Manager modules and configurations
- `hosts/` - Example host configurations
- `lib/` - Custom library functions
- `vars/` - Variables and constants
- `overlays/` - Package overlays

## Hosts

This repository includes example configurations for:

- `mbair` - Personal MacBook Air (macOS)
- `enduro` - Linux laptop
- `tinkerdell` - Linux laptop

## Development

This flake includes a Justfile for common operations:

```bash
just build        # Build the system
just switch       # Apply configuration
just update       # Update flake inputs
just gc           # Garbage collect
```

## License

MIT License - see [LICENSE](LICENSE) for details.
