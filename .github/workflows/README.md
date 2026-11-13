# GitHub Actions

The workflows validate the flake and maintain dependency pins. They use generated input stubs rather than access to private secrets.

## Build check

[`build-check.yml`](build-check.yml) runs on pushes and pull requests to `main`, and on manual dispatch.

| Job                       | Runner | Coverage                                                                 |
| ------------------------- | ------ | ------------------------------------------------------------------------ |
| `check`                   | Ubuntu | `nix flake check --all-systems`, Android HM evaluation, `just fmt-check` |
| `discover-configurations` | Ubuntu | Discover Darwin hosts, standalone HM hosts, and package outputs          |
| `build-darwin`            | macOS  | Dry-run builds of discovered Darwin targets                              |
| `build-linux`             | Ubuntu | Dry-run builds of discovered standalone Linux HM targets, when present   |
| `test-packages`           | Ubuntu | Dry-run builds of discovered packages across the supported architectures |

**Dry-run is not a full build.** The configuration and package jobs invoke `nix build --dry-run`; they do not prove that every derivation builds or that activation succeeds. Build locally with `just darwin-build` before switching a Mac.

There are currently no standalone `homeConfigurations`, so the Linux HM build job has no targets. macOS Home Manager is checked through the Darwin system configuration.

### Android evaluation

`nix flake check` does not validate the nonstandard `nixOnDroidConfigurations` output. The `check` job explicitly evaluates:

```text
nixOnDroidConfigurations.pixel6.config.home-manager.config.home.activationPackage.drvPath
```

The Android activation environment depends on on-device proot paths. CI does not build or activate it, and interactive tools still need testing on the phone.

### Manual inputs

- `darwin-hosts`: optional comma-separated Darwin host list.
- `linux-hosts`: optional comma-separated Linux host list.

Leaving these empty uses flake discovery. They feed host classification during discovery; they do not create outputs or provide a general filter for all build targets. If discovery changes, review the shell logic and output shapes in the workflow together with `flake.nix`.

## Dependency updates

[`update-dependencies.yml`](update-dependencies.yml) runs on Sundays at **02:00 UTC**, or manually from the Actions tab.

Manual inputs:

- `update-type`: `all`, `nixpkgs`, `nix-darwin`, `home-manager`, `catppuccin`, `nvf`, or `other`.
- `create-pr`: request PR creation/update (default: `true`).
- `branch-name`: branch prefix (default: `update-dependencies`). The target branch is appended, for example `update-dependencies-main`.

The workflow resets the update branch from the target branch, updates the selected inputs, commits and force-pushes `flake.lock` if it changes, then runs `nix flake check --all-systems` with stub overrides. PR creation/update follows validation.

Important details:

- `all` and `other` both update every direct input **except private `nix-secrets`**.
- Individual choices target their named inputs; `catppuccin` targets `catppuccin` and `catppuccin-vsc`, not every theme input.
- Disabling PR creation does not disable the update branch commit/push.
- Keep the choice list and update cases in sync when renaming flake inputs.
- Updates to `nix-secrets` must be made from an authorized local checkout, using `just upp nix-secrets`.

## Input stubs

Both workflows run [`scripts/gen-stubs.sh`](../../scripts/gen-stubs.sh). It creates:

- Empty `.age` files under `stub-flake-for-ci/nix-secrets/`, based on secret-path references in the source tree.
- A minimal `stub-flake-for-ci/wallpapers/desktop/` directory to avoid fetching the wallpaper collection.

Nix validation commands use `NIX_SECRETS_OVERRIDE` and `NIX_WALLPAPERS_OVERRIDE` with `--override-input`. New literal secret references are discovered automatically; changes to reference structure may require updating the generator.

Stubs support evaluation and dry runs only. Never activate a host with these inputs. The local equivalent is `just gen-stubs`; see the [secrets guide](../../secrets/README.md#ci-and-stub-handling).

## Runners, caching, and permissions

- Darwin jobs use the Determinate Nix installer and Magic Nix Cache.
- Ubuntu jobs use `cachix/install-nix-action`, `nix-community/cache-nix-action`, and, where configured, read-only access to the `nix-community` Cachix cache (`skipPush: true`).
- Dependency updates use the built-in `GITHUB_TOKEN`. Repository or organization policy must permit branch pushes and PR creation; check Actions workflow permissions if these steps fail.
- PRs and pushes made with `GITHUB_TOKEN` generally do not trigger other workflows. Do not assume an automatically opened update PR has run the build-check workflow; verify its checks or dispatch it manually.

CI does not need SSH credentials for `nix-secrets`. Never add plaintext machine secrets to workflow files or logs.
