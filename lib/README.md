# Local library

`lib/default.nix` collects the repository's helper functions. `flake.nix` adds `relativeToRoot` and passes the result to modules as `mylib`:

```nix
mylib =
  import ./lib {inherit lib;}
  // {
    relativeToRoot = lib.path.append ./.;
  };
```

These helpers are internal module arguments, not an exported `lib.mylib` flake output.

## Helpers

| Source                | Exports                                   |
| --------------------- | ----------------------------------------- |
| `scan-paths.nix`      | `scanPaths`                               |
| `editable-config.nix` | `mkEditableConfig`, `mkEditableConfigDir` |
| `flake.nix`           | `relativeToRoot`                          |

### `scanPaths`

Returns immediate child paths in name order:

- Directories, except those whose names start with `_`.
- Names ending in `.nix`, except `default.nix` itself.

It is not recursive; imported directories usually provide their own `default.nix`. The underscore exclusion applies to directories only: `_example.nix` is still included. Documentation and other non-Nix files are skipped.

```nix
imports = mylib.scanPaths ./modules;
```

### `relativeToRoot`

Builds a repository-root-relative path, avoiding deep chains of `../` in modules:

```nix
imports = [
  (mylib.relativeToRoot "vars/features.nix")
];
```

### `mkEditableConfig`

Generates a Home Manager activation snippet that writes a **regular, editable file** when the destination is absent or already a regular file. If the existing file differs, activation copies it to `<configPath>.home-manager.backup` and displays a diff before overwriting it. It does not prompt for confirmation; subsequent activations replace manual edits and reuse the same backup path.

Existing destination symlinks are **not** replaced: the helper's `cp` and `chmod` follow them, so a symlink into the Nix store causes activation to fail. When migrating from `home.file` or `xdg.configFile`, first remove the old declaration and activate that change to retire its managed symlink. Back up any remaining destination content and remove any remaining symlink before enabling this helper. Do not modify the symlink's Nix-store target.

```nix
home.activation.myApp = lib.hm.dag.entryAfter ["writeBoundary"] (mylib.mkEditableConfig {
  name = "myapp";
  configPath = "$HOME/.config/myapp/config";
  content = "config content here";
  inherit pkgs;
  isJson = false;
  executable = false;
});
```

- `pkgs` is optional; supplying it uses Delta for diffs and enables jq formatting when `isJson = true`.
- Files receive mode `0644`, or `0755` when `executable = true`.
- Destination writes respect Home Manager's dry-run variables; a temporary file is still used to prepare the content.
- `content` is part of the Nix-generated activation script. **Do not use this helper for secrets.**

### `mkEditableConfigDir`

Applies the same editable-file behavior to regular files in a source directory, recursively preserving their relative paths:

```nix
home.activation.copySketchybarConfig = lib.hm.dag.entryAfter ["writeBoundary"] (mylib.mkEditableConfigDir {
  name = "sketchybar";
  configDir = "$HOME/.config/sketchybar";
  sourceDir = ./config;
  inherit pkgs;
});
```

The helper applies JSON formatting to recognized `.json` files when `pkgs` is supplied, and marks recognized `.sh` files and `sketchybarrc` executable. Extension detection currently uses the segment after the first dot, so prefer simple names such as `config.json` and `start.sh`.

This is a recursive **copy**, not an exact mirror: source symlinks are skipped and files removed from the source are not deleted from the destination. Backups, permissions, and overwrite behavior match `mkEditableConfig`.
