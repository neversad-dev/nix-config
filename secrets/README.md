# Machine secrets

Application and website passwords belong in a password manager. This directory configures **machine secrets** that Nix needs to materialize at runtime, such as API tokens and deploy keys.

Never put plaintext secrets in this repository, Nix expressions, shell history, or chat. Nix-store files are not a secure place for credentials.

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

Use `agenix -e` to create or edit ciphertext using the recipients declared in `secrets.nix`. Use an editor without persistent backups, swap, or undo files, and enter only the secret value. Avoid creating a plaintext file in either checkout.

Use your **user** key for editing. Host keys decrypt at runtime, but they are root-owned and should not be used for editing. The user key must already be a recipient to decrypt an existing ciphertext:

```bash
agenix -e hosts/mbair/work-vpn.age -i ~/.ssh/id_ed25519
agenix -e shared/openrouter-pi.age -i ~/.ssh/id_ed25519
```

### 3. Wire it in this repo

**Host-specific** (declared in that host's module):

```nix
# hosts/mbair/secrets.nix
age.secrets."work-vpn" = {
  file = "${nix-secrets}/hosts/mbair/work-vpn.age";
  owner = myvars.primaryUser;
  mode = "0400";
};
```

**Shared across Darwin hosts** (declared centrally):

```nix
# secrets/darwin.nix
age.secrets."openrouter-pi" = {
  file = "${nix-secrets}/shared/openrouter-pi.age";
  owner = myvars.primaryUser;
  mode = "0500";
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

### 4. Pin, build, and apply

Commit and push the ciphertext and recipient changes in `nix-secrets` first. Then, from the `nix-config` repository root:

```bash
just upp nix-secrets
just darwin-build mbair
just darwin mbair
```

`just upp` updates the selected input and commits `flake.lock`. Replace `mbair` with the configured host name when targeting another Mac. An unpinned ciphertext will not be available during deployment.

## CodeCompanion OpenRouter key

Create a separate key from pi in [OpenRouter settings](https://openrouter.ai/settings/keys),
preferably with a small credit limit. In **nix-secrets**, register it with the
same recipients as pi (including every Darwin host):

```nix
"./shared/openrouter-codecompanion.age".publicKeys = admins ++ workstations;
```

Encrypt **only the API key**, using an editor without persistent backups/undo:

```bash
agenix -e shared/openrouter-codecompanion.age -i ~/.ssh/id_ed25519
```

Commit/push the ciphertext and recipient declaration, then in **nix-config**:

```bash
just upp nix-secrets
just darwin-build mbair
just darwin mbair
```

On Darwin, agenix decrypts `openrouter-codecompanion` with mode `0400`, owned by
the primary user. CodeCompanion reads it at runtime via `cmd:`; the key stays
out of the Nix store and separate from pi. The ciphertext must exist in the
pinned input before deployment; CI stubs are evaluation-only.
See [Neovim usage](../home/base/tui/neovim/README.md#codecompanion-and-pi).

## GitHub CLI token

`home/base/core/git/gh.nix` enables `gh` with SSH for Git operations, preserving
existing SSH authentication. On Darwin, a wrapper reads the `github-cli` secret
at invocation time and exports `GH_TOKEN` only to `gh` and its child processes
(including extensions). It works in scripts as well as interactive shells.
The token is not embedded in the Nix store or written to gh's credential storage;
agenix does materialize a decrypted, owner-readable file at runtime. Explicit
`GH_TOKEN` or `GITHUB_TOKEN` environment variables override the managed token.
Android gets plain `gh` without a managed token.

### Create a personal access token

Tokens belong to your **account**, not necessarily one repository. Create one at
[GitHub → Settings → Developer settings → Personal access tokens](https://github.com/settings/personal-access-tokens).

- **Fine-grained (recommended):** choose your account as resource owner and select
  multiple repositories, or **All repositories** for current and future repos
  owned by that account. Grant only the permissions you need: for example,
  Contents (read for browsing, write for pushing), Pull requests and Issues
  (read/write if you want to manage them), and Actions (read for viewing runs,
  write for triggering/cancelling them). Metadata read access is automatic.
  One fine-grained token is limited to **one resource owner** (your account or
  one organization); it does not cover unrelated owners. Some `gh` operations
  require additional permissions or do not support fine-grained tokens.
- **Classic:** useful when you need broader coverage across your own repos and
  organizations/collaborator repos that allow classic tokens. GitHub CLI's
  documented baseline scopes are `repo`, `read:org`, and `gist`; add `workflow`
  only if needed to modify workflow files. `repo` grants broad private-repository
  access, so prefer fine-grained tokens when they cover your use case.

A token cannot grant permissions your account does not have. Organizations may
require approval, SSO authorization, or disallow a token type. Set an expiration
and rotate the encrypted secret when renewing it. `GH_HOST` is unnecessary for
normal github.com usage.

### Encrypt and deploy

In your private **nix-secrets** checkout:

1. Add `"./shared/github-cli.age".publicKeys = admins ++ workstations;` to
   `secrets.nix`, using the same recipients as `shared/openrouter-pi.age`.
2. Run the following and put **only the token** in the editor (no `GH_TOKEN=`):

   ```bash
   nix shell github:yaxitech/ragenix#ragenix
   agenix -e shared/github-cli.age -i ~/.ssh/id_ed25519
   ```

   Use an editor without persistent backups/undo for secrets. Do not paste the
   token into shell commands, this repo, or chat.

3. Commit and push the ciphertext and recipient declaration.

Back in **nix-config**:

```bash
just upp nix-secrets
just darwin-build mbair
just darwin mbair
# Open a new shell so gh is on PATH, then:
gh auth status
gh api user --jq .login
gh repo list
```

No `gh auth login` is needed. Do not run `gh auth token` or
`gh auth status --show-token` in logs: they can print the secret. Until the real
ciphertext is present in the pinned `nix-secrets` input, deployment will fail;
CI stubs are for evaluation only.

## Adding a new host or machine

### Darwin (new Mac)

1. Complete [GitHub SSH setup](../hosts/README.md#1-set-up-github-ssh-access) from the host guide. The user key provides repository access; it is distinct from the system key that decrypts secrets.
2. Generate the host key **only if it does not already exist**. Never overwrite an enrolled host key:
   ```bash
   sudo ssh-keygen -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key -C "root@$(hostname)"
   ```
3. Copy the public key off the machine:
   ```bash
   cat /etc/ssh/ssh_host_ed25519_key.pub
   ```
4. On a machine that can already decrypt `nix-secrets`: add the new host pubkey and user pubkey as recipients in `nix-secrets/secrets.nix`, rekey (`agenix -r -i <key>`), commit/push.
5. Update this flake's input with `just upp nix-secrets` from an authorized checkout, then transfer or pull the updated lock file on the new Mac.
6. On the new Mac, build with `just darwin-build <host>` before applying with `just darwin <host>`, using the host name defined in `flake.nix`.

### NixOS (new server)

This is a future-host reference, not a supported output today: the flake has no `nixosConfigurations`. Add a system configuration and agenix integration before using these installation patterns.

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

## CI and stub handling

CI runners have no SSH access to `nix-secrets`. The generator scans source directories for literal paths into the `nix-secrets` input and creates matching empty `.age` files so evaluation can proceed. If a new reference format is not recognized, update `scripts/gen-stubs.sh`.

```bash
just gen-stubs   # local equivalent (also generates wallpapers stub)
```

The generated directories are gitignored. CI passes both input overrides to its validation commands:

```text
--override-input nix-secrets path:./stub-flake-for-ci/nix-secrets
--override-input wallpapers path:./stub-flake-for-ci/wallpapers
```

Generating stubs does not select them automatically. **Never activate a host with stub inputs:** the empty files are not valid ciphertext and cannot decrypt. See the [workflow guide](../.github/workflows/README.md#input-stubs) for coverage and limitations.

## Troubleshooting activation

**Darwin** — agenix logs:

```bash
tail -n 100 /Library/Logs/org.nixos.activate-agenix.stderr.log
tail -n 100 /Library/Logs/org.nixos.activate-agenix.stdout.log
```

**Home Manager** — inspect the output of the embedded nix-darwin activation. For verbose rebuild output, use `just darwin-debug mbair` (this **switches** the configuration; it is not a read-only diagnostic). There is no standalone Home Manager output, so `home-manager switch --flake .` does not apply to this repository.

Check that the required `.age` file exists in the **pinned** `nix-secrets` revision, the system key is a recipient, and the decrypted file is owned by the intended user. Do not print secret contents while debugging.

## Why ragenix/agenix

The flake uses `agenix.url = "github:yaxitech/ragenix"` and imports `agenix.darwinModules.default`. ragenix provides an agenix-compatible module interface and Rust CLI; the recipient and ciphertext workflow remains the same.
