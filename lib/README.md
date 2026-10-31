# lib

Local library functions.

`lib/default.nix` re-exports everything; `flake.nix` wires it into `mylib`:

```nix
mylib =
  import ./lib {inherit lib;}
  // {
    relativeToRoot = lib.path.append ./.;
  };
```

## Layout

| File                  | Exports                                   |
| --------------------- | ----------------------------------------- |
| `scan-paths.nix`      | `scanPaths`                               |
| `editable-config.nix` | `mkEditableConfig`, `mkEditableConfigDir` |

## Functions

### `scanPaths`

Scans a directory and returns a list of paths to all `.nix` files and directories, excluding entries starting with `_` and any `default.nix`.

```nix
imports = mylib.scanPaths ./modules;
```

### `mkEditableConfig`

Creates an activation snippet that writes a config file, backing up any existing file to `<name>.home-manager.backup` and showing a diff before overwriting. Pass `pkgs` to get `delta` diffs and `jq` formatting (for `isJson`).

```nix
home.activation.myApp = lib.hm.dag.entryAfter ["writeBoundary"] (mylib.mkEditableConfig {
  name = "myapp";
  configPath = "$HOME/.config/myapp/config";
  content = "config content here";
  pkgs = pkgs;      # optional: delta diff + jq
  isJson = false;   # optional: format with jq
  executable = false; # optional: chmod 755
});
```

### `mkEditableConfigDir`

Same as `mkEditableConfig`, but recursively mirrors a source directory into a target config directory, preserving structure. `.json` files are formatted with `jq`; `.sh` files and `sketchybarrc` are marked executable.

```nix
home.activation.copySketchybarConfig = lib.hm.dag.entryAfter ["writeBoundary"] (mylib.mkEditableConfigDir {
  name = "sketchybar";
  configDir = "$HOME/.config/sketchybar";
  sourceDir = ./config;
  pkgs = pkgs; # optional
});
```
