# Neovim

Custom Neovim configuration built with [nvf](https://nvf.notashelf.dev), vendored from [neversad-dev/nvf-config](https://github.com/neversad-dev/nvf-config).

`default.nix` is the Home Manager module: it enables `programs.nvf`, exposes `features.cli.neovim.enable`, and imports the sibling nvf modules into `programs.nvf.settings` via `mylib.scanPaths`. The siblings set `vim.*` options and run inside nvf's settings submodule, not the usual Home Manager context.

Enable with `features.cli.neovim.enable = true` (off by default, unused on Android). Run standalone with `nix run github:neversad-dev/nix-config`.

## Layout

```
home/base/tui/neovim/
├── default.nix         # Home Manager module: feature flag + nvf settings
├── core.nix            # Aliases, leader, spellcheck, autopairs
├── ui.nix              # UI and visual options
├── theme.nix           # Catppuccin
├── keymaps.nix         # which-key, cheatsheet
├── languages.nix       # LSP, formatting, language options
├── autocomplete.nix    # blink-cmp
├── debugger.nix        # nvim-dap
├── plugins/            # Per-plugin nvf modules
│   ├── default.nix     # Imports every plugin module
│   └── ...
└── README.md
```
