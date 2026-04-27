# GitHub Actions — reminder

What runs in CI for this repo and what I touch when I change behavior.

## `build-check.yml`

- **When:** pushes + PRs to `main`, plus **workflow_dispatch** with optional **`darwin-hosts`** / **`linux-hosts`** (comma-separated; leave empty to auto-detect from the flake).
- **Why I care:** validates the flake, formatting, discovers darwin/linux outputs, builds/dry-runs so I do not merge a broken lock or module set.
- **Private `mysecrets` on CI:** the workflow sets `NIX_MYSECRETS_OVERRIDE` to `secrets/ci-stub-for-flake` so evaluation does not need my real nix-secrets checkout. If I add new secret *names* required at eval time, stub or override accordingly.
- **If discovery breaks:** grep this file for hard-coded host names or job filters.

## `update-dependencies.yml`

- **When:** weekly cron + manual dispatch.
- **What it does:** bumps inputs (nixpkgs, nix-darwin, home-manager, theme pins, ghostty, etc. — see workflow inputs), optionally opens a PR.
- **Manual run:** Actions tab → workflow → “Run workflow” → `update-type`, `create-pr`, optional **`branch-name`** (defaults to `update-dependencies`).

Inputs map to flake input IDs I defined; if I rename inputs in `flake.nix`, update the workflow’s choice list too.

## Caching / runners

- Darwin jobs use the Determinate Nix installer + macOS runners; Linux uses Ubuntu + Cachix installer.
- Cachix + Magic Nix Cache show up in the YAML — if cache names or tokens change, fix secrets/settings in repo settings, not just locally.

## Secrets

Default **`GITHUB_TOKEN`** is enough for PR creation from the update workflow. Anything else (Cachix signing, private substituters) I document in repo **Settings → Secrets** when I add it; this file is my reminder to check there if auth starts failing.
