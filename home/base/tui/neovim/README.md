# Neovim

Neovim configured with [nvf](https://nvf.notashelf.dev), using modules vendored from [neversad-dev/nvf-config](https://github.com/neversad-dev/nvf-config). The configuration lives in this repository; nvf itself remains a flake input.

## Home Manager and standalone use

`default.nix` is a Home Manager module. It declares `features.cli.neovim.enable` (disabled by default), enables `programs.nvf`, and imports sibling modules through `mylib.scanPaths` into `programs.nvf.settings`.

Enable it in a host's home entry point:

```nix
features.cli.neovim.enable = true;
```

The sibling modules set `vim.*` options inside nvf's settings submodule. They do **not** receive the usual Home Manager `config`; host-dependent settings must be passed in or applied from `default.nix`.

From the repository root, `just nvim` runs the standalone package. The remote form is `nix run github:neversad-dev/nix-config`. These packages include the shared nvf settings but not Home Manager-only AI credentials or CodeCompanion enablement. Evaluating the flake may still require the private input described in the [root README](../../../../README.md#before-you-start).

The standalone package always keeps its Catppuccin theme. Home Manager respects the host's `features.theme.catppuccin.enable` flag.

### Android

The shared language presets also apply on Android. Missing language-tool packages are aliased from nixos-25.11 in `flake.nix`, and the Neovim binary is selected from that set in `home/android/default.nix`. Avoid replacing it with an unstable binary without on-device testing; see [Android constraints](../../../../hosts/android/README.md#compatibility-constraints).

## CodeCompanion and pi

CodeCompanion is enabled only for a **Darwin Home Manager host** with both Neovim and `features.ai.enable` enabled. It is disabled on Android and in the standalone package.

It uses a [dedicated OpenRouter key](../../../../secrets/README.md#codecompanion-openrouter-key), read from an agenix runtime file through `cmd:`. The default model is `openrouter/auto`, configured in `default.nix`. pi keeps its own credentials and conversation.

| Shortcut     | Action (normal/visual mode) |
| ------------ | --------------------------- |
| `<leader>aa` | Open the action palette     |
| `<leader>ac` | Toggle chat                 |
| `<leader>ai` | Start an inline prompt/edit |

For inline suggestions, the shared diff defaults use `g2`/`g3` to accept/reject all changes. Press `?` in chat for the installed plugin's help and use `:checkhealth codecompanion` for diagnostics. File-editing tools may write directly, so do not assume every change uses the inline accept/reject flow.

Use CodeCompanion for editor tasks and pi for larger work, but avoid concurrent edits to the same files. Attached code and tool-provided context may be sent to OpenRouter and its model provider; do not attach plaintext secrets or decrypted credential files.

## Layout

```text
home/base/tui/neovim/
├── default.nix         # HM feature flag, nvf integration, Darwin AI setup
├── core.nix            # Aliases, leader, spellcheck, autopairs
├── ui.nix              # UI and visual options
├── theme.nix           # Catppuccin
├── keymaps.nix         # which-key, cheatsheet
├── languages.nix       # LSP, formatters, language options
├── autocomplete.nix    # blink-cmp
├── plugins/            # Per-plugin nvf modules
│   ├── default.nix     # Imports plugin modules
│   └── codecompanion.nix
└── README.md
```

Add shared editor settings to the appropriate nvf module. Keep host-specific enablement and system-secret paths in the Home Manager layer, then format and validate before rebuilding.
