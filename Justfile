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
  nix build .#darwinConfigurations.{{hostname}}.system \
    --extra-experimental-features 'nix-command flakes' \
    --accept-flake-config

  ./result/sw/bin/darwin-rebuild switch --flake .#{{hostname}}


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
  nix flake update --commit-lock-file --accept-flake-config

# Update specific input
# Usage: just upp nixpkgs
[group('nix')]
upp input:
  nix flake update {{input}} --commit-lock-file --accept-flake-config

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
  

[group('tools')]
fmt:
  # format the nix files in this repo
  nix fmt . --accept-flake-config

[group('tools')]
nvim:
  # run neovim
  nix run .#nvim \
    --extra-experimental-features 'nix-command flakes' \
    --accept-flake-config