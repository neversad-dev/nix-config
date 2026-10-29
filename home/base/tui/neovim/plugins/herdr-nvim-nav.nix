{pkgs, ...}: {
  vim = {
    extraPlugins = {
      herdr-nvim-nav = {
        package = pkgs.vimUtils.buildVimPlugin {
          pname = "herdr-nvim-nav";
          version = "unstable";
          src = pkgs.fetchFromGitHub {
            owner = "aimdevlee";
            repo = "herdr-nvim-nav";
            rev = "ec047fd6d8d0269d54a34e9405af28d8aad4c8f0"; # Pin a specific commit for strict reproducibility
            hash = "sha256-2Sa10OaDgoy/Mw3lglrnmJn4RLUJv0dfU0MhXxXdnJI="; # Replace with actual hash
          };
        };
        # nvf automatically evaluates this string as Lua code upon plugin load
        setup = ''
          require('herdr-nvim-nav').setup({
            with_tmux = false
          })
        '';
      };
    };

    keymaps = [
      {
        key = "<C-w>h";
        mode = "n";
        action = "<Nop>";
      }
      {
        key = "<C-w>j";
        mode = "n";
        action = "<Nop>";
      }
      {
        key = "<C-w>k";
        mode = "n";
        action = "<Nop>";
      }
      {
        key = "<C-w>l";
        mode = "n";
        action = "<Nop>";
      }
    ];

    # Talk directly to which-key v3 to hide them from the UI
    luaConfigRC.hide_window_movements = ''
      -- We wrap this in a pcall (protected call) or standard require
      -- to ensure it only runs if which-key is loaded
      vim.api.nvim_create_autocmd("User", {
        pattern = "DeferredUIEnter",
        callback = function()
          vim.schedule(function()
            local wk_ok, wk = pcall(require, "which-key")
            if wk_ok then
              wk.add({
                { "<C-w>h", hidden = true },
                { "<C-w>j", hidden = true },
                { "<C-w>k", hidden = true },
                { "<C-w>l", hidden = true },
              })
            end
          end)
        end,
      })
    '';
  };
}
