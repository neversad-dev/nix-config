# just is a command runner, Justfile is very similar to Makefile, but simpler.

hostname := if env_var_or_default("HOSTNAME", "") != "" { env_var_or_default("HOSTNAME", "") } else { `sh -c 'hostname 2>/dev/null || cat /proc/sys/kernel/hostname 2>/dev/null || echo unknown'` }
user := env_var_or_default("USER", `whoami`)

# List all the just commands
default:
  @just --list

############################################################################
#
#  Project todo.txt (tuxedo)
#
#  Manage project tasks with tuxedo instead of GitHub issues.
#  Commands below operate on ./todo.txt in this repo.
#  Tuxedo is available in the nix develop shell.
#
############################################################################

# Open project todo.txt in tuxedo TUI
[group('project')]
todo:
  tuxedo ./todo.txt

# Add a task to project todo.txt (supports natural language)
# Usage: just todo-add "Review PR +project @work due:tomorrow"
[group('project')]
todo-add text:
  TODO_FILE=./todo.txt tuxedo add {{ quote(text) }}

# List project tasks (optionally filter by project/context/free text)
[group('project')]
todo-ls *term:
  tuxedo ls {{ term }}

# Mark task number N as done
[group('project')]
todo-done n:
  tuxedo do {{ n }}

# Move completed tasks to done.txt
[group('project')]
todo-archive:
  tuxedo archive

############################################################################
#
#  Darwin related commands
#
############################################################################

[group('desktop')]
darwin host="":
  nh darwin switch .{{ if host != "" { " -H " + host } else { "" } }}

[group('desktop')]
darwin-build host="":
  nh darwin build .{{ if host != "" { " -H " + host } else { "" } }}

[group('desktop')]
darwin-debug host="":
  nh darwin switch . --verbose{{ if host != "" { " -H " + host } else { "" } }}

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
home host="":
  nh home switch .{{ if host != "" { " -c " + user + "@" + host } else { "" } }}

[group('home-manager')]
home-build host="":
  nh home build .{{ if host != "" { " -c " + user + "@" + host } else { "" } }}

# Legacy home-manager command (kept for compatibility)
[group('home-manager')]
home-legacy:
  home-manager switch --flake . \
    -b home-manager.backup \
    --extra-experimental-features 'nix-command flakes' \
    --accept-flake-config

############################################################################
#
# Nix-on-Droid related commands
#
############################################################################

[group('nix-on-droid')]
droid host="pixel6":
  nix-on-droid switch --flake .#{{ host }}

[group('nix-on-droid')]
droid-build host="pixel6":
  nix-on-droid build --flake .#{{ host }}

# Clean up garbage on nix-on-droid:
# - delete old generations of the system + HM (and the current one if -d twice)
# - wipe old nix profile generations
# - collect garbage from the store
[group('nix-on-droid')]
droid-clean:
  nix-collect-garbage -d
  nix profile wipe-history --profile ~/.nix-profile 2>/dev/null || true
  nix-collect-garbage -d
  nix store optimise

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
gen-stubs:
  # Generate CI stub directories for nix-secrets and wallpapers
  bash scripts/gen-stubs.sh

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

# Run the configured Neovim directly; extra args are forwarded
# Usage: just nvim -- --version
[group('tools')]
nvim *args:
  nix run .#nvim \
    --extra-experimental-features 'nix-command flakes' \
    --accept-flake-config \
    -- {{ args }}
