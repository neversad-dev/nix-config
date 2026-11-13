{
  config,
  lib,
  ...
}: let
  cfg = config.vim.assistant.codecompanion-nvim;
in {
  # Enabled by the Home Manager module only when managed AI secrets are available.
  # Standalone Neovim and Android keep this disabled.
  config = lib.mkIf cfg.enable {
    # Pinned nvf emits obsolete inline accept/reject keymaps without `modes`.
    # Omit them so CodeCompanion uses its current inline and shared diff defaults.
    vim.lazy.plugins.codecompanion-nvim.setupOpts = lib.mkForce (cfg.setupOpts
      // {
        interactions =
          cfg.setupOpts.interactions
          // {
            inline = builtins.removeAttrs cfg.setupOpts.interactions.inline ["keymaps"];
          };
      });

    vim.assistant.codecompanion-nvim.setupOpts.interactions = {
      chat.adapter = "openrouter";
      inline.adapter = "openrouter";
      background.adapter = "openrouter";
    };

    vim.keymaps = [
      {
        key = "<leader>aa";
        mode = ["n" "v"];
        action = "<cmd>CodeCompanionActions<CR>";
        desc = "AI action palette";
      }
      {
        key = "<leader>ac";
        mode = ["n" "v"];
        action = "<cmd>CodeCompanionChat Toggle<CR>";
        desc = "AI chat";
      }
      {
        key = "<leader>ai";
        mode = ["n" "v"];
        action = "<cmd>CodeCompanion<CR>";
        desc = "AI inline edit";
      }
    ];
  };
}
