# Nix Configuration

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

## Structure

- `modules/` - nix-darwin system modules
- `home/` - Home Manager modules  
- `hosts/` - Example host configurations
- `lib/` - Custom library functions
- `vars/` - Variables and constants

---

MIT License - Open source configuration for the Nix community.