# `vars/` — reminder

Where I centralize identity (`myvars`) and the shared `features.*` option schema so nix-darwin and Home Manager agree.

## Layout

```
vars/
├── README.md
├── default.nix    # primaryUser, initialHashedPassword, SSH keys
└── features.nix   # options only: features.*
```

## `default.nix`

Flake does `myvars = import ./vars` → this file.

- **`primaryUser`** — drives `home/<username>/` paths and HM output names in `flake.nix`.
- **`initialHashedPassword`** — yescrypt hash; comments in-file for regeneration.
- **`mainSshAuthorizedKeys`** — keys I trust everywhere; optional backup list if I uncomment/extend it.

## `features.nix`

Module with **`options.features` only** (no `config`). I import it from `modules/common/default.nix` and `home/common/default.nix` so both stacks expose the same toggles (desktop fonts, dev editors, Android `javaHome`, gaming, stay-awake, etc.).

## Wiring `myvars` / `features`

- **`myvars`** — already in `specialArgs` from `flake.nix`; I use it in hosts and HM for user + keys + password.
- **`features.*`** — I set values in `hosts/<hostname>/features.nix`. In feature modules I gate with `lib.mkIf config.features.<path>.enable` (or nested paths).

No `networking.nix` here — if I ever want a host table, I add a file and document it.

## Shared `features.nix` per host

I define flags once, import the same file from darwin + HM.

```nix
# hosts/myhost/features.nix
{
  features = {
    development = {
      cursor.enable = true;
      vscode.enable = false;
      android.enable = false;
    };
    gaming.enable = false;
  };
}
```

```nix
# hosts/myhost/default.nix
{ imports = [ ./features.nix ]; /* … */ }
```

```nix
# home/<user>/myhost.nix
{ mylib, ... }: {
  imports = [
    (mylib.relativeToRoot "hosts/myhost/features.nix")
    ./home.nix
    ../common
    ../features/cli
    ../features/desktop
    ../features/darwin # or ../features/linux
    ../features/development
  ];
}
```

Then I add `homeConfigurations."<user>@myhost"` in `flake.nix` pointing at `home/<user>/myhost.nix` (and any extra modules).

## Adding a new `features` flag

1. **`features.nix`** — under `options.features`, add `mkEnableOption` / `mkOption` next to the right group.

```nix
{ lib, ... }:
with lib; {
  options.features.mygroup.myFeature.enable = mkEnableOption "…";
}
```

2. **Consumer module** — `config = lib.mkIf config.features.mygroup.myFeature.enable { … };`

3. **Host `features.nix`** — set `features.mygroup.myFeature.enable = true/false;` and keep darwin + HM imports in sync (see above).

**Rules I try to follow:** `mkIf` for conditionals, consistent `*.enable` names, real `description` on options, default new toggles to `false` unless I mean global opt-in.

Quick list of existing names: root README → [`features.*` cheat sheet](../README.md#features-cheat-sheet).
