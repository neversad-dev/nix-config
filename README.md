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

# Linux Home Manager  
nix build .#homeConfigurations."${USER}@linux-vm"
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
      modules = [ nix-config.homeModules.default ];
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

## Example Hosts

- `mbair` - Personal MacBook Air (macOS)
- `enduro` - Linux laptop
- `tinkerdell` - Linux laptop

## Configuration Options

- `development.cursor.enable` - Enable Cursor editor configurations (default: false)
- `development.vscode.enable` - Enable VSCode editor configurations (default: false)
- `development.android.enable` - Enable Android development configurations (default: false)
- `gaming.enable` - Enable gaming-related packages (default: false)

### Usage Examples

**Recommended: Shared Configuration File**
```nix
# hosts/myhost/config.nix (shared configuration)
{
  development.cursor.enable = true;   # Enable Cursor editor
  development.vscode.enable = false; # Disable VSCode editor
  development.android.enable = false; # Disable Android development
  gaming.enable = false;  # Disable gaming packages
}

# hosts/myhost/home.nix (imports shared config)
{
  imports = [ ./config.nix ];
}

# hosts/myhost/default.nix (imports shared config)
{
  imports = [ ./config.nix ];
}
```

**Important**: Use shared config files to avoid duplication and ensure consistency.

### Adding New Options

1. **Define the option** in `vars/config.nix`:
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

3. **Set the option** in shared host config:
```nix
# hosts/myhost/config.nix (shared configuration)
myFeature.enable = true;

# hosts/myhost/home.nix (imports shared config)
{
  imports = [ ./config.nix ];
}

# hosts/myhost/default.nix (imports shared config)
{
  imports = [ ./config.nix ];
}
```

**Rules:**
- Always use `lib.mkIf` for conditional configurations
- Follow the `featureName.enable` naming convention
- Document options with clear descriptions
- Set sensible defaults (usually `false` for optional features)

## Structure

- `modules/` - nix-darwin system modules
- `home/` - Home Manager modules  
- `hosts/` - Example host configurations
- `lib/` - Custom library functions
- `vars/` - Variables and constants

---

MIT License - Open source configuration for the Nix community.