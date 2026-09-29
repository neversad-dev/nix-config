# just is a command runner, Justfile is very similar to Makefile, but simpler.

hostname := `hostname`

# List all the just commands
default:
        @just --list

############################################################################
#
#  Darwin related commands
#
############################################################################

[group('desktop')]
darwin:
        nh darwin switch .

[group('desktop')]
darwin-build:
        nh darwin build . 

[group('desktop')]
darwin-debug:
        nh darwin switch . --verbose

# Legacy darwin command (kept for compatibility)
[group('desktop')]
darwin-legacy:
        nix build .#darwinConfigurations.{{ hostname }}.system \
          --extra-experimental-features 'nix-command flakes' \
          --accept-flake-config

        ./result/sw/bin/darwin-rebuild switch --flake .#{{ hostname }}

############################################################################
#
#  Home-manager related commands
#
############################################################################

[group('home-manager')]
home:
        nh home switch .

[group('home-manager')]
home-build:
        nh home build .

# Legacy home-manager command (kept for compatibility)
[group('home-manager')]
home-legacy:
        home-manager switch --flake . \
          -b home-manager.backup \
          --extra-experimental-features 'nix-command flakes' \
          --accept-flake-config

############################################################################
#
#  nix related commands
#
############################################################################

# Update all the flake inputs
[group('nix')]
up:
        nix flake update --commit-lock-file --accept-flake-config --option commit-lockfile-summary "chore(flake): update inputs"

# Update specific input
# Usage: just upp nixpkgs
[group('nix')]
upp input:
        nix flake update {{ input }} --commit-lock-file --accept-flake-config --option commit-lockfile-summary "chore(flake): update {{ input }}"

# List all generations of the system profile
[group('nix')]
history:
        nix profile history --profile /nix/var/nix/profiles/system

# Open a nix shell with the flake
[group('nix')]
repl:
        nix repl -f flake:nixpkgs --accept-flake-config

# Clean old generations and garbage collect with nh
[group('nix')]
clean:
        nh clean all --keep 3

# Legacy garbage collection (kept for compatibility)
[group('nix')]
gc-legacy:
        # garbage collect all unused nix store entries(system-wide)
        sudo nix-collect-garbage --delete-older-than 7d
        # garbage collect all unused nix store entries(for the user - home-manager)
        # https://github.com/NixOS/nix/issues/8508
        nix-collect-garbage --delete-older-than 7d

# Show all the auto gc roots in the nix store
[group('nix')]
gcroot:
        ls -al /nix/var/nix/gcroots/auto/

# Generate dummy .age stub files for CI so the flake evaluates without the private nix-secrets repo
[group('tools')]
[group('tools')]
gen-stubs:
        # Generate CI stub directories for nix-secrets and wallpapers
        bash scripts/gen-stubs.sh

# Kept for backward compatibility; alias to gen-stubs
gen-secrets-stub: gen-stubs

[group('tools')]
fmt:
        # Format Nix files with alejandra
        nix fmt . --accept-flake-config
        # Format Markdown, YAML, and JSON files with prettier
        prettier --write --no-error-on-unmatched-pattern "**/*.md" "**/*.yml" "**/*.yaml" "**/*.json"
        # Format Shell scripts with shfmt
        shfmt -w -i 2 -sr .
        # Format TOML files with taplo
        git ls-files "*.toml" | xargs -r taplo fmt

[group('tools')]
fmt-check:
        # Check Nix files with alejandra
        nix fmt . --accept-flake-config -- --check
        # Check Markdown, YAML, and JSON files with prettier
        prettier --check --no-error-on-unmatched-pattern "**/*.md" "**/*.yml" "**/*.yaml" "**/*.json"
        # Check Shell scripts with shfmt
        shfmt -d -i 2 -sr .
        # Check TOML files with taplo
        git ls-files "*.toml" | xargs -r taplo fmt --check


[group('tools')]
nvim:
        # run neovim
        nix run .#nvim \
          --extra-experimental-features 'nix-command flakes' \
          --accept-flake-config

