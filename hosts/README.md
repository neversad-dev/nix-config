# Hosts

This directory contains per-host configurations and the bootstrap guide.

## Current hosts

| Host       | Platform               |      System       |    Home Manager     | Purpose           |
| ---------- | ---------------------- | :---------------: | :-----------------: | ----------------- |
| **mbair**  | macOS / aarch64        |        ✅         | embedded in darwin  | Daily driver      |
| **enduro** | Linux / x86_64         |         —         |  `neversad@enduro`  | Secondary desktop |
| **pixel6** | Android (nix-on-droid) | ✅ (nix-on-droid) | via built-in module | Phone             |

## Bootstrap a new machine

### macOS (nix-darwin)

1. **Generate a per-machine SSH keypair** (one key per host, never copied between devices):
   ```bash
   ssh-keygen -t ed25519 -a 256 -C "$USER@$(hostname)" -f ~/.ssh/id_ed25519
   ```
2. **Add the public key to GitHub:**
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
   - Paste it as an **Authentication key**
   - Paste it _again_ as a **Signing key** so GitHub can verify signed commits
3. **Pin GitHub's host key** before first clone to avoid TOFU:
   ```bash
   mkdir -p ~/.ssh
   printf '%s\n' 'github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl' >> ~/.ssh/known_hosts
   chmod 600 ~/.ssh/known_hosts
   ```
   Verification: [GitHub's SSH key fingerprints](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)
4. **Clone via SSH** (this repo depends on a private `nix-secrets` input):
   ```bash
   git clone git@github.com:neversad-dev/nix-config.git
   cd nix-config
   ```
5. **Verify GitHub access** (this triggers the first passphrase prompt):
   ```bash
   ssh -T git@github.com
   ```
   `UseKeychain` + `AddKeysToAgent` in the declarative SSH config handle caching from then on.
6. **Generate the host SSH key for agenix** (decrypts system-level secrets):
   ```bash
   sudo ssh-keygen -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key -C "root@$(hostname)"
   ```
7. **Enroll both keys in `nix-secrets`** before rebuilding:
   - Add `~/.ssh/id_ed25519.pub` and `/etc/ssh/ssh_host_ed25519_key.pub` as recipients in `nix-secrets/secrets.nix`
   - Rekey the `.age` files and push
   - Update this flake's `nix-secrets` input to the new revision
   - See [secrets/README.md](../secrets/README.md) for the enrollment flow
8. **Build and switch** (system + embedded Home Manager):
   ```bash
   just darwin
   ```

### Linux (Home Manager only)

Same as macOS for steps 1–5. Skip step 6 (no system-level agenix on HM-only Linux). Run:

```bash
just home
```

### NixOS server (future)

NixOS generates host keys when OpenSSH starts, but **agenix needs the key earlier** for the first rebuild. Two options:

**Option A (recommended):** Pre-generate during `nixos-install`:

```bash
sudo mkdir -p /mnt/etc/ssh
sudo ssh-keygen -t ed25519 -N "" -f /mnt/etc/ssh/ssh_host_ed25519_key -C "root@newhost"
```

Copy the `.pub` off the installer, add it to `nix-secrets/secrets.nix`, rekey, update flake input, then run `nixos-install --flake .#newhost`. Secrets decrypt on first boot.

**Option B:** Two-phase bootstrap. Install a minimal config with **no secret references** first, let NixOS generate the key naturally, then enroll it in `nix-secrets` and rebuild.

See [secrets/README.md](../secrets/README.md#adding-a-new-host-or-machine) for full details.

### nix-on-droid (Android)

Same as macOS for steps 1–5 (in Termux). Then switch on-device:

```bash
just droid pixel6   # first time; afterwards plain `just droid` ($HOSTNAME is set by HM)
```

nix-on-droid pins against nixpkgs/home-manager 24.05 (dedicated flake inputs). Home Manager is wired through nix-on-droid's built-in module rather than a standalone `homeConfigurations` output. See [android/README.md](android/README.md).

## Adding a new host

1. Create `hosts/<hostname>/` (system config) and `home/hosts/<platform>/<hostname>.nix` (home entry point; see [home/README.md](../home/README.md))
2. Add flake output in `flake.nix`
3. Follow the bootstrap steps above
4. Update this table
