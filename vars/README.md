# Variables and feature flags

This directory holds identity values, shared feature options, and font settings. `myvars` supplies plain Nix values; `features.*` supplies typed module options.

## Layout

| File           | Purpose                                                        |
| -------------- | -------------------------------------------------------------- |
| `default.nix`  | Identity values: username, password hash, and trusted SSH keys |
| `features.nix` | Feature option declarations shared by nix-darwin and HM        |
| `fonts.nix`    | Shared font settings                                           |

## Identity: `myvars`

`flake.nix` imports `default.nix` as `myvars` and passes it to system modules and Home Manager through their module arguments.

- `primaryUser` sets the default Home Manager username, platform-specific home directory, and the embedded Darwin user configuration.
- `initialHashedPassword` is a yescrypt hash available to modules that need it; it does not itself configure a login password. Regeneration notes are in `default.nix`.
- `mainSshAuthorizedKeys` contains trusted public keys available to host modules. Keep private keys on the devices that generated them.

Changing `primaryUser` is not an account migration. Review host user declarations and existing home directories before applying a new value.

## Shared and Home Manager-only options

`features.nix` declares options only; it does not enable features. It is imported by `modules/common/default.nix` for system configuration and by `home/base/home.nix` for Home Manager.

The shared groups currently cover:

- `features.development.{cursor,vscode,android}.enable`
- `features.gaming.enable`
- `features.stayAwake.enable`
- `features.theme.catppuccin.enable`

Home Manager-only options, such as `features.cli.*`, `features.desktop.*`, and `features.ai.enable`, are declared in their owning home modules. Set these in the home entry point, not in a flags file also imported by nix-darwin.

## Share flags between system and home modules

A Darwin host can import the same flags file from both module trees. The existing example is [`hosts/mbair/features.nix`](../hosts/mbair/features.nix).

For a new host, create `hosts/myhost/features.nix` with shared options:

```nix
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

Import `./features.nix` from the system host module. Then import it alongside the platform stack in `home/hosts/darwin/myhost.nix`:

```nix
{mylib, ...}: {
  imports = [
    (mylib.relativeToRoot "hosts/myhost/features.nix")
    ../../darwin
  ];

  features.cli.neovim.enable = true;
}
```

Finally, point the system's embedded Home Manager configuration at that home entry point. See the [host guide](../hosts/README.md#adding-a-new-host).

## Add a feature flag

1. Declare a cross-cutting system/HM option in `features.nix`, or an HM-only option in its owning home module.
2. Use `lib.mkEnableOption` for an opt-in Boolean flag and gate its configuration with `lib.mkIf`.
3. Enable it in the appropriate shared host flags file or Home Manager entry point.
4. If a shared module uses HM options newer than 24.05, update [`home/android/compat.nix`](../home/android/compat.nix) or explicitly guard unsupported integrations.
5. Format and validate before building the affected host.

For example, an HM-only leaf module can declare and consume its own option:

```nix
{config, lib, ...}: {
  options.features.cli.example.enable =
    lib.mkEnableOption "example CLI integration";

  config = lib.mkIf config.features.cli.example.enable {
    # Program configuration goes here.
  };
}
```

Prefer descriptive option names, consistent `*.enable` paths, and disabled-by-default optional features. For the flags enabled on each machine, read [`home/hosts/darwin/mbair.nix`](../home/hosts/darwin/mbair.nix) and [`home/hosts/android/pixel6.nix`](../home/hosts/android/pixel6.nix).
