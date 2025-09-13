# GitHub Actions Workflows

This directory contains 2 GitHub Actions workflows for the nix-config repository. These workflows provide comprehensive testing and automated dependency management.

## Workflows

### 1. Build Check (`build-check.yml`)

**Purpose**: Comprehensive build validation for all configurations and packages.

**Triggers**:
- Push to main branches
- Pull requests to main branches
- Manual dispatch with optional host selection

**Features**:
- Checks flake validity and formatting
- Auto-discovers Darwin and Linux configurations
- Builds all configurations with dry-run validation
- Tests standalone packages

### 2. Update Dependencies (`update-dependencies.yml`)

**Purpose**: Automatically updates flake dependencies.

**Triggers**:
- Weekly schedule (Sundays at 2 AM UTC)
- Manual dispatch

**Features**:
- Updates all or specific dependencies
- Validates updated dependencies before creating PRs
- Creates pull requests with updates
- Configurable update types

**Manual Inputs**:
- `update-type`: Type of update (all, nixpkgs, nix-darwin, home-manager, catppuccin, ghostty, nvf-config, other)
- `create-pr`: Whether to create a pull request (default: true)

## Key Features

### Automated Dependency Management

The update dependencies workflow supports selective updates for:
- **nixpkgs**: Core Nix packages
- **nix-darwin**: macOS system management
- **home-manager**: User environment management
- **catppuccin**: Theme packages (catppuccin + catppuccin-vsc)
- **ghostty**: Terminal emulator
- **nvf-config**: Neovim configuration
- **all/other**: All dependencies

### Multi-Platform Support

- **Darwin**: Uses macOS runners with DeterminateSystems Nix installer
- **Linux**: Uses Ubuntu runners with Cachix Nix installer
- **Cross-platform**: Supports x86_64 and aarch64 architectures

### Caching

- Uses Cachix for Nix package caching
- Magic Nix Cache for macOS builds
- Optimized for faster builds

## Usage

### Running Workflows Manually

1. Go to the Actions tab in your GitHub repository
2. Select the desired workflow
3. Click "Run workflow"
4. Configure inputs if needed
5. Click "Run workflow"

### Monitoring Workflows

- Check the Actions tab for workflow status
- Review logs for detailed information
- Set up notifications for workflow failures

## Configuration

### Required Secrets

No additional secrets are required beyond the default `GITHUB_TOKEN`.

### Optional Configuration

- Modify the `nix-community` Cachix cache if needed
- Adjust scheduling times in cron expressions
- Configure notification preferences
