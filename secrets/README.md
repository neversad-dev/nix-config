# Secrets — reminder

App/site passwords stay in a password manager. Here I only care about **machine secrets** Nix should materialize (tokens, deploy keys, etc.).

Ciphertext lives in **[nix-secrets](https://github.com/neversad-dev/nix-secrets)** (private). This flake pulls it as **`nix-secrets`** and decrypts via the agenix-compatible module (`inputs.agenix` → `agenix.darwinModules.default` / `agenix.homeManagerModules.default`).

## Two levels of decryption

| Level               | Identity key                    | Where declared                            | Use for                                       |
| ------------------- | ------------------------------- | ----------------------------------------- | --------------------------------------------- |
| **System (Darwin)** | `/etc/ssh/ssh_host_ed25519_key` | `hosts/<host>/secrets.nix`                | Root-level secrets (VPNs, system certs, etc.) |
| **User**            | `~/.ssh/id_ed25519`             | Any home-manager module via `age.secrets` | API keys, app configs, user tokens            |

**In this tree:**

- `secrets/darwin.nix` — imports the agenix Darwin module and sets the **system-level** identity path. No `age.secrets` declarations here anymore.
- `home/common/secrets.nix` — imports the agenix home-manager module and sets the **user-level** identity path.
- `hosts/<host>/secrets.nix` — host-specific system secrets.
- `home/features/<feature>/` — feature-specific user secrets (e.g. `home/features/ai/pi.nix` for OpenRouter API key).

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
  mbair_host = "ssh-ed25519 AAAA... root@mbair";
  neversad_user = "ssh-ed25519 AAAA... neversad@mbair";
  recovery_key = "ssh-ed25519 AAAA... neversad@agenix-recovery";
in {
  "./shared/openrouter-pi.age".publicKeys = [ neversad_user recovery_key ];
  "./hosts/mbair/work-vpn.age".publicKeys = [ mbair_host recovery_key ];
}
```

### 2. Create/edit the ciphertext

```bash
# For a user-level secret (encrypt for your user key)
age -r <your-user-pubkey> -o shared/openrouter-pi.age plaintext.txt

# For a host-level secret (encrypt for host key)
sudo age -r <host-pubkey> -o hosts/mbair/work-vpn.age plaintext.txt

# Or via agenix REPL
agenix -e shared/openrouter-pi.age -i ~/.ssh/id_ed25519
```

### 3. Wire it in this repo

**User-level** (home-manager):

```nix
# home/features/some-feature/default.nix
age.secrets."my-secret" = {
  file = "${nix-secrets}/shared/my-secret.age";
  path = "${config.xdg.dataHome}/secrets/my-secret";  # optional explicit path
};

# Pi supports command-backed credential values; other applications need their own runtime loading mechanism.
home.file.".pi/agent/auth.json".text = builtins.toJSON {
  openrouter = {
    type = "api_key";
    key = "!cat ${config.age.secrets."my-secret".path}";
  };
};
```

**System-level** (darwin/nixos):

```nix
# hosts/mbair/secrets.nix
age.secrets."work-vpn" = {
  file = "${nix-secrets}/hosts/mbair/work-vpn.age";
  owner = "neversad";
  mode = "0400";
};
```

### 4. Rebuild

```bash
just darwin   # or just home, depending on where the secret is declared
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

Same module surface as agenix; Rust CLI errors are usually easier to parse when I typo `secrets.nix`. The flake input is `agenix.url = "github:yaxitech/ragenix"` but exposes both `agenix.darwinModules.default` and `agenix.homeManagerModules.default`.
