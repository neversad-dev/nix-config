# Secrets — reminder

App/site passwords stay in a password manager. Here I only care about **machine secrets** Nix should materialize (tokens, deploy keys, etc.).

Ciphertext lives in **[nix-secrets](https://github.com/neversad-dev/nix-secrets)** (private). This flake pulls it as **`nix-secrets`** and decrypts via the agenix-compatible module (`inputs.agenix` → `agenix.darwinModules.default`).

## How secrets are decrypted

All secrets are **system-level** and use each Darwin host's SSH host key as the
identity. There is no Home Manager agenix module; HM modules read the decrypted
system secret via `osConfig.age.secrets`.

| Level                         | Identity key                    | Where declared             | Use for                               |
| ----------------------------- | ------------------------------- | -------------------------- | ------------------------------------- |
| **System (Darwin, shared)**   | `/etc/ssh/ssh_host_ed25519_key` | `secrets/darwin.nix`       | Secrets intended for all Darwin hosts |
| **System (Darwin, per-host)** | `/etc/ssh/ssh_host_ed25519_key` | `hosts/<host>/secrets.nix` | Host-specific system secrets          |

**In this tree:**

- `secrets/darwin.nix` — imports the agenix Darwin module, sets the **system-level** identity path, and declares secrets shared across Darwin hosts.
- `hosts/<host>/secrets.nix` — placeholder for secrets specific to that host; each is decrypted with that host's system key.
- `home/base/tui/` feature modules — read system secrets (e.g. `home/base/tui/ai/pi.nix` uses the OpenRouter API key).
- nix-on-droid does not support system-level agenix secrets; its `hosts/android/<host>/secrets.nix` is only a documented placeholder. No secrets are currently used on Android.

## Adding or changing a secret

Work in **`nix-secrets`**, not in cleartext here.

```bash
# agenix CLI (ragenix-compatible)
nix shell github:yaxitech/ragenix#ragenix
# or legacy agenix
nix shell github:ryantm/agenix#agenix
```

### 1. Register the secret in nix-secrets

Edit `secrets.nix` in the private repo. Declare which keys can decrypt it:

```nix
let
  neversad_user = "ssh-ed25519 AAAA... neversad@mbair";
  recovery_key = "ssh-ed25519 AAAA... neversad@agenix-recovery";
  mbair_host = "ssh-ed25519 AAAA... root@mbair";
  admins = [ neversad_user recovery_key ];
  workstations = [ mbair_host ];
in {
  # Shared: every Darwin host must be listed here
  "./shared/openrouter-pi.age".publicKeys = admins ++ workstations;
  # Per-host: only this host (plus admins/recovery) can decrypt
  "./hosts/mbair/work-vpn.age".publicKeys = admins ++ [ mbair_host ];
}
```

### 2. Create/edit the ciphertext

Encrypt for the intended host key(s), plus any recovery key:

```bash
sudo age -r <host-pubkey> -r <recovery-pubkey> \
  -o hosts/mbair/work-vpn.age plaintext.txt

# Or via agenix REPL
agenix -e shared/openrouter-pi.age -i /etc/ssh/ssh_host_ed25519_key
```

### 3. Wire it in this repo

**System-level** (darwin/nixos):

```nix
# secrets/darwin.nix
age.secrets."work-vpn" = {
  file = "${nix-secrets}/shared/work-vpn.age";
  owner = "neversad";
  mode = "0400";
};
```

All Darwin hosts import `secrets/darwin.nix` for shared system-level secrets.
A ciphertext declared there must be decryptable by every Darwin host. Put
host-specific declarations in that host's `hosts/<host>/secrets.nix` instead,
and encrypt the ciphertext for that host's system key (plus any recovery key).

Home Manager modules read a declared secret through `osConfig`, for example:

```nix
key = "!cat ${osConfig.age.secrets."my-secret".path}";
```

### 4. Rebuild

```bash
just darwin
```

## Adding a new host or machine

### Darwin (new Mac)

1. Finish the [bootstrap steps in hosts/README.md](../hosts/README.md#bootstrap-a-new-machine) (generate user key, add to GitHub, clone repo, verify SSH).
2. Generate the host key:
   ```bash
   sudo ssh-keygen -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key -C "root@$(hostname)"
   ```
3. Copy the public key off the machine:
   ```bash
   cat /etc/ssh/ssh_host_ed25519_key.pub
   ```
4. On a machine that can already decrypt `nix-secrets`: add the new host pubkey and user pubkey as recipients in `nix-secrets/secrets.nix`, rekey (`agenix -r -i <key>`), commit/push.
5. Update this flake's `nix-secrets` input to the new revision.
6. On the new Mac: `just darwin` to rebuild with working secrets.

### NixOS (new server)

NixOS generates host keys when OpenSSH starts, but **agenix needs the key before it can decrypt secrets**. You have two options:

**Option A: Pre-generate during install (recommended)**

1. During `nixos-install`, after partitioning/mounting but before running the install command:
   ```bash
   sudo mkdir -p /mnt/etc/ssh
   sudo ssh-keygen -t ed25519 -N "" -f /mnt/etc/ssh/ssh_host_ed25519_key -C "root@newhost"
   ```
2. Copy `/mnt/etc/ssh/ssh_host_ed25519_key.pub` to your existing machine.
3. On the existing machine: add the pubkey to `nix-secrets/secrets.nix`, rekey, commit/push.
4. Point the flake's `nix-secrets` input at the updated revision.
5. Run `nixos-install --flake .#newhost`.
6. Reboot — secrets work on first boot because the key already exists.

**Option B: Two-phase bootstrap**

1. Create a minimal NixOS config with **no `age.secrets` declarations at all** (not even stubbed ones). CI stubs only make `nix flake check` work; they do not survive agenix activation.
2. `nixos-install --flake .#newhost` and reboot.
3. NixOS generates the host key naturally. Copy it:
   ```bash
   cat /etc/ssh/ssh_host_ed25519_key.pub
   ```
4. On an existing machine: add the pubkey to `nix-secrets/secrets.nix`, rekey, commit/push.
5. Update flake lock, then `nixos-rebuild switch` on the new host.

### Rekeying agenix secrets

```bash
# After editing nix-secrets/secrets.nix (adding/removing recipients)
nix shell github:yaxitech/ragenix#ragenix
agenix -r -i ~/.ssh/id_ed25519   # re-encrypts all files with updated recipients
```

## CI / stub handling

CI runners have no SSH access to `nix-secrets`. The workflow auto-generates empty `.age` stub files from all `${nix-secrets}` references so evaluation succeeds:

```bash
just gen-stubs   # local equivalent (also generates wallpapers stub)
```

Stubs are created in `stub-flake-for-ci/nix-secrets/` (gitignored) and overridden via:

```
--override-input nix-secrets path:./stub-flake-for-ci/nix-secrets
```

## Troubleshooting activation

**Darwin** — agenix logs:

```bash
tail -n 100 /Library/Logs/org.nixos.activate-agenix.stderr.log
tail -n 100 /Library/Logs/org.nixos.activate-agenix.stdout.log
```

**Home-manager** — check the activation script output or run:

```bash
home-manager switch --flake . --verbose
```

## Why ragenix/agenix

Same module surface as agenix; Rust CLI errors are usually easier to parse when I typo `secrets.nix`. The flake input is `agenix.url = "github:yaxitech/ragenix"`; this repo uses `agenix.darwinModules.default`.
