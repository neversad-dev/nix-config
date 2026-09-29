# Secrets — reminder

App/site passwords stay in a password manager. Here I only care about **machine secrets** Nix should materialize (tokens, deploy keys, etc.).

Ciphertext lives in **[nix-secrets](https://github.com/neversad-dev/nix-secrets)** (private). This flake pulls it as **`nix-secrets`** and decrypts via the agenix-compatible module (`inputs.agenix` → `agenix.darwinModules.default` / `agenix.homeManagerModules.default`).

## Two levels of decryption

| Level | Identity key | Where declared | Use for |
|-------|-------------|----------------|---------|
| **System (Darwin)** | `/etc/ssh/ssh_host_ed25519_key` | `hosts/<host>/secrets.nix` | Root-level secrets (VPNs, system certs, etc.) |
| **User** | `~/.ssh/id_ed25519` | Any home-manager module via `age.secrets` | API keys, app configs, user tokens |

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

1. Grab the host pubkey: `cat /etc/ssh/ssh_host_ed25519_key.pub` (or `sudo ssh-keygen -A` first if missing).
2. On a machine that can decrypt: add the new pubkey to `nix-secrets/secrets.nix` for each relevant `.age`, rekey (`agenix -r -i <key>`), commit/push.
3. On the new machine: same flake + new `darwinConfiguration`, then rebuild.

## CI / stub handling

CI runners have no SSH access to `nix-secrets`. The workflow auto-generates empty `.age` stub files from all `${nix-secrets}` references so evaluation succeeds:

```bash
just gen-secrets-stub   # local equivalent
```

Stubs are created in `secrets/ci-stub-for-flake/` (gitignored) and overridden via:

```
--override-input nix-secrets path:./secrets/ci-stub-for-flake
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
