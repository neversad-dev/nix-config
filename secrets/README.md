# Secrets Management

> App and website passwords live in a password manager; here I only track **machine secrets** (tokens, keys, etc.) that Nix should deploy.

Ciphertext lives in **[nix-secrets](https://github.com/neversad-dev/nix-secrets)** (private). This flake pulls it as **`mysecrets`** and decrypts on the Mac with **[agenix](https://github.com/ryantm/agenix)-style** options via **[ragenix](https://github.com/yaxitech/ragenix)** (`inputs.agenix`, module `agenix.darwinModules.default`).

I encrypt for host pubkeys from **`/etc/ssh/ssh_host_ed25519_key.pub`**; decryption uses **`/etc/ssh/ssh_host_ed25519_key`** (root-only, stays on the machine). Stuff in `/nix/store` stays encrypted until activation.

**In this repo:** `README.md` + **`darwin.nix`** (wired from `hosts/mbair/default.nix`). No `nixos.nix` yet - mirror the same pattern on NixOS if I ever need it.

**Current `age.secrets`:** see `darwin.nix` (`secret1`, `neversad-secrets` and paths there). Any new `.age` file needs a matching entry there **and** in [`nix-secrets`](https://github.com/neversad-dev/nix-secrets/blob/main/secrets.nix), then `just darwin`.

## When I add or change a secret

Work happens in **`nix-secrets`**, not here. I use **`secrets.nix`** + agenix or ragenix:

```bash
nix shell github:ryantm/agenix#agenix
# or
nix shell github:yaxitech/ragenix#ragenix
```

1. In `nix-secrets`, extend **`secrets.nix`** for `./xxx.age` (pubkeys = hosts / recovery / whatever I still use).

```nix
# CLI only — not imported by nix-darwin

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

2. Edit or create the file:

```shell
sudo agenix -e ./xxx.age -i /etc/ssh/ssh_host_ed25519_key
# or pipe plaintext:
cat xxx | sudo agenix -e ./xxx.age -i /etc/ssh/ssh_host_ed25519_key
```

3. Commit/push **`nix-secrets`**, then in **this** repo add **`age.secrets`** in `darwin.nix` if it is a new name, bump flake lock if I care about revision pinning, and **`darwin-rebuild switch`**.

## When I add another Mac

1. New machine: `cat /etc/ssh/ssh_host_ed25519_key.pub` (or `sudo ssh-keygen -A` first).
2. On a box that can decrypt: add pubkey to `secrets.nix` for each relevant `.age`, then `sudo agenix -r -i /etc/ssh/ssh_host_ed25519_key`, commit/push **`nix-secrets`**.
3. New machine: same flake + `darwinConfiguration` (or shared `secrets/darwin.nix`), then `sudo darwin-rebuild switch --flake .`.

## If something breaks

**Darwin —** agenix activate logs:

```bash
tail -n 100 /Library/Logs/org.nixos.activate-agenix.stderr.log
tail -n 100 /Library/Logs/org.nixos.activate-agenix.stdout.log
```

**NixOS —** if I ever wire it:

```bash
journalctl | grep agenix
```

## Why ragenix

Same module surface as agenix; Rust CLI tends to give less cryptic errors than the bash agenix when I typo `secrets.nix`.
