# Neovim

Custom Neovim configuration built with [nvf](https://nvf.notashelf.dev), vendored from [neversad-dev/nvf-config](https://github.com/neversad-dev/nvf-config).

`default.nix` is the Home Manager module: it enables `programs.nvf`, exposes `features.cli.neovim.enable`, and imports the sibling nvf modules into `programs.nvf.settings` via `mylib.scanPaths`. The siblings set `vim.*` options and run inside nvf's settings submodule, not the usual Home Manager context.

Enable with `features.cli.neovim.enable = true` (off by default). Run standalone with `nix run github:neversad-dev/nix-config` (always the full config).

`languages.nix` (LSP, formatters) works everywhere; on Android the
packages its presets need but nixpkgs-24.05 lacks are aliased from
nixos-25.11 in flake.nix (the nvim binary itself comes from 25.11 too,
see home/android/default.nix).

## CodeCompanion + pi

CodeCompanion is enabled on Darwin with Neovim + `features.ai.enable`, but not
on Android or in the standalone package. It uses a
[dedicated OpenRouter key](../../../../secrets/README.md#codecompanion-openrouter-key),
read through agenix at runtime; pi keeps its own credentials and conversation.
The default model is `openrouter/auto` (set in `default.nix`).

| Shortcut     | Action (normal/visual mode) |
| ------------ | --------------------------- |
| `<leader>aa` | Action palette              |
| `<leader>ac` | Toggle chat                 |
| `<leader>ai` | Inline prompt/edit          |

Accept/reject inline edits with `ga`/`gr`; press `?` in chat for help.
Use CodeCompanion for small editor tasks and pi for larger work; avoid concurrent
edits to the same file. Attached code is sent to OpenRouter and its model provider.
Troubleshoot with `:checkhealth codecompanion`.

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
├── plugins/            # Per-plugin nvf modules
│   ├── default.nix     # Imports every plugin module
│   └── ...
└── README.md
```
