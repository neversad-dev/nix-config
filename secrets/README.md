# Secrets — reminder

App/site passwords stay in a password manager. Here I only care about **machine secrets** Nix should materialize (tokens, deploy keys, etc.).

Ciphertext lives in **[nix-secrets](https://github.com/neversad-dev/nix-secrets)** (private). This flake pulls it as **`mysecrets`** and decrypts on the Mac with ragenix (agenix-compatible module; `inputs.agenix` → `agenix.darwinModules.default`).

I encrypt for host pubkeys from **`/etc/ssh/ssh_host_ed25519_key.pub`**; activation reads **`/etc/ssh/ssh_host_ed25519_key`** (root-only). Store paths stay ciphertext until activation.

**In this tree:** wire secrets in **`secrets/darwin.nix`** (or whatever I import from `hosts/.../default.nix`). No NixOS secrets module wired yet — copy the same idea if I add a NixOS host.

**What names exist:** open `secrets/darwin.nix` for the current `age.secrets` map. Every new `.age` blob needs a matching entry there **and** in `nix-secrets`’s `secrets.nix`, then rebuild.

## When I add or change a secret

Work in **`nix-secrets`**, not in cleartext here.

```bash
nix shell github:ryantm/agenix#agenix
# or
nix shell github:yaxitech/ragenix#ragenix
```

1. Extend **`secrets.nix`** in nix-secrets for `./xxx.age` (pubkeys = hosts + recovery key I still use).

```nix

let
  mbair = "ssh-ed25519 AAAA... root@mbair";
  recovery_key = "ssh-ed25519 AAAA... neversad@agenix-recovery";

  users = [ ];

  systems = [
    mbair
    recovery_key
  ];
in {
  "./xxx.age".publicKeys = users ++ systems;
}
```

2. Edit ciphertext:

```shell
sudo agenix -e ./xxx.age -i /etc/ssh/ssh_host_ed25519_key
# or
cat xxx | sudo agenix -e ./xxx.age -i /etc/ssh/ssh_host_ed25519_key
```

3. Commit/push **nix-secrets**, then here: add/update **`age.secrets`** in my darwin secrets module, bump lock if I pin that input, **`darwin-rebuild switch`**.

## When I add another Mac

1. Grab `cat /etc/ssh/ssh_host_ed25519_key.pub` (or `sudo ssh-keygen -A` first if keys missing).
2. On a machine that can decrypt: add the new pubkey to `secrets.nix` for each relevant `.age`, run `sudo agenix -r -i /etc/ssh/ssh_host_ed25519_key`, commit/push **nix-secrets**.
3. On the new Mac: same flake + new `darwinConfiguration`, then `sudo darwin-rebuild switch --flake .`.

## If activation misbehaves

**Darwin** — agenix/ragenix logs:

```bash
tail -n 100 /Library/Logs/org.nixos.activate-agenix.stderr.log
tail -n 100 /Library/Logs/org.nixos.activate-agenix.stdout.log
```

**NixOS** (if I ever wire it): `journalctl | grep agenix`.

## Why ragenix

Same module surface as agenix; Rust CLI errors are usually easier to parse when I typo `secrets.nix`.
