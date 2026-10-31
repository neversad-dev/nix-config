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
            hash = "sha256-2Sa10OaDgoy/Mw3lglrnmJn4RLUJv0dfU0MhXxXdnJI=";
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
      {
        key = "<C-h>";
        mode = "n";
        lua = true; # interpret the action as Lua code
        action = ''
          function()
            require('herdr-nvim-nav').left()
          end
        '';
      }
      {
        key = "<C-j>";
        mode = "n";
        lua = true; # interpret the action as Lua code
        action = ''
          function()
            require('herdr-nvim-nav').down()
          end
        '';
      }
      {
        key = "<C-k>";
        mode = "n";
        lua = true; # interpret the action as Lua code
        action = ''
          function()
            require('herdr-nvim-nav').up()
          end
        '';
      }
      {
        key = "<C-l>";
        mode = "n";
        lua = true; # interpret the action as Lua code
        action = ''
          function()
            require('herdr-nvim-nav').right()
          end
        '';
      }
    ];
  };
}
