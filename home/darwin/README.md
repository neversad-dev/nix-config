# Darwin home stack

`default.nix` combines shared identity, core, TUI, and GUI modules with the macOS-only modules in this directory. These include AeroSpace, SketchyBar, and the `ghgrab` repository browser.

## Configuration boundaries

- **Host choices:** [`home/hosts/darwin/mbair.nix`](../hosts/darwin/mbair.nix) selects the stack and enables Home Manager features.
- **Shared flags:** `hosts/mbair/features.nix` is imported by both the system and home configurations.
- **System settings and Homebrew apps:** `modules/darwin/` owns macOS defaults, services, and native application installation. Prefer Homebrew casks for GUI apps; Home Manager manages user configuration.
- **Secrets:** the system decrypts them with agenix; home modules reference runtime paths through `osConfig`.

## Build and apply

Home Manager runs inside nix-darwin, configured by `hosts/mbair/default.nix`. From the repository root:

```bash
just darwin-build mbair  # build without activation
just darwin mbair        # apply system and user configuration together
```

The host name can be omitted after local host setup. There is no separate `just home` recipe or standalone Home Manager output to switch.

See the [host bootstrap guide](../../hosts/README.md) before applying this stack to a new Mac.
