# Hosts

System configurations live here; per-host Home Manager entry points live under [`home/hosts/`](../home/README.md). Home Manager is embedded in the platform's system configuration, not applied separately.

## Current hosts

| Host   | Platform                | System directory  | Home Manager integration |
| ------ | ----------------------- | ----------------- | ------------------------ |
| mbair  | macOS / aarch64-darwin  | `mbair/`          | Embedded in nix-darwin   |
| pixel6 | Android / aarch64-linux | `android/pixel6/` | Built into nix-on-droid  |

## Before bootstrapping

- Install Nix with `nix-command` and `flakes` enabled. On macOS, follow the [nix-darwin installation guide](https://github.com/nix-darwin/nix-darwin#installing) if nix-darwin is not already bootstrapped.
- Review `vars/default.nix`, the host's system configuration, and its Home Manager flags. Do not apply another machine's identity or keys unchanged.
- Normal evaluation requires access to the private `nix-secrets` input. If reusing this repository independently, replace that input and its declarations first.
- Generate keys only when missing. **Do not overwrite an existing user or host private key.** Replacing a host key can break both SSH trust and secret decryption.

## Bootstrap a Mac

### 1. Set up GitHub SSH access

Generate a passphrase-protected, per-machine key if one does not already exist:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t ed25519 -a 256 -C "$USER@$(hostname)" -f ~/.ssh/id_ed25519
```

Add `~/.ssh/id_ed25519.pub` to GitHub as an **Authentication key**. Add it separately as a **Signing key** if this host will sign commits. Never copy the private key between devices.

Before connecting, verify GitHub's host key against its [published SSH key fingerprints](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints). Do not trust unverified `ssh-keyscan` output as proof of identity.

```bash
ssh -T git@github.com
git clone git@github.com:neversad-dev/nix-config.git
cd nix-config
```

GitHub's successful authentication message says it does not provide shell access; an exit status of 1 is normal for this test. Repository access to private `nix-secrets` must also be granted to the account.

After activation, the declarative SSH settings use `UseKeychain` and `AddKeysToAgent` for macOS passphrase caching.

### 2. Enroll the machine for secrets

If `/etc/ssh/ssh_host_ed25519_key` does not exist, generate it:

```bash
sudo mkdir -p /etc/ssh
sudo ssh-keygen -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key -C "root@$(hostname)"
```

From an already authorized `nix-secrets` checkout:

1. Add the new host **public** key to the recipients for every secret it needs.
2. Add the user's public key if it should have editing/recovery access.
3. Rekey the ciphertexts, commit, and push.
4. In `nix-config`, update the pin with `just upp nix-secrets` once the development tools are available.

The [secrets guide](../secrets/README.md#adding-a-new-host-or-machine) describes recipients and rekeying. The host key decrypts system secrets during activation; the user key authenticates to GitHub and can edit secrets only when enrolled as a recipient.

### 3. Build before switching

Enter the development environment after SSH access is working:

```bash
nix develop
just darwin-build mbair
just darwin mbair
```

Replace `mbair` with your configured flake host name. The build does not activate anything; the switch applies both system settings and Home Manager. Once the machine is configured, `just darwin` can infer the local host.

## Bootstrap Android

Use the **nix-on-droid environment**, not a plain Termux shell. Install the app and initialize it before using this flake.

1. Set up a per-device user SSH key and GitHub access as above. macOS Keychain settings do not apply.
2. Clone the repository and review the phone's flags. Avoid the default `nix develop` shell on Android: it uses unstable packages, not the phone's compatible package set, and can trigger the terminal issues described in the [Android guide](android/README.md#compatibility-constraints).
3. Run `just droid pixel6` on-device, or `nix-on-droid switch --flake .#pixel6` if `just` is unavailable. After the first switch, a new shell receives `HOSTNAME=pixel6`, so plain `just droid` works.

Do not follow the Darwin host-key or agenix enrollment steps: Android currently has no managed secrets in this repository. Access to the private flake input may still be required during evaluation.

nix-on-droid, its base nixpkgs, and Home Manager are pinned to 24.05. See the [Android guide](android/README.md) for package constraints, font setup, and on-device testing.

## Future NixOS hosts

There is currently no `nixosConfigurations` output. The reusable [Linux home stacks](../home/linux/README.md) do not constitute a bootable system configuration.

When adding a NixOS host with agenix, arrange for its SSH host key to exist before secret activation. The [secrets guide](../secrets/README.md#nixos-new-server) describes pre-generation and two-phase installation.

## Adding a new host

1. Create a system module under `hosts/<hostname>/` for Darwin, or `hosts/android/<device>/` for Android.
2. Create `home/hosts/<platform>/<hostname>.nix`, import a platform stack, and set host-specific `features.*` flags.
3. Wire that home entry point into the system's Home Manager integration.
4. Add the corresponding output in `flake.nix`. For Darwin, pass shared flags to both module trees if needed.
5. Enroll required secret recipients before activation, then format, evaluate, and build the configuration.
6. Update the host tables here and in the root README.
