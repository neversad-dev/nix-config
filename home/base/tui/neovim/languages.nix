{pkgs, ...}: {
  vim = {
    visuals.fidget-nvim.enable = true; # Shows LSP progress notifications in the corner

    options = {
      expandtab = true; # Use spaces instead of tabs
      shiftwidth = 2; # Size of an indent
      tabstop = 2; # Number of spaces tabs count for
      softtabstop = 2;
    };

    autocmds = [
      {
        # Enforce 2 spaces for Nix, Web, and Config languages
        event = ["FileType"];
        pattern = [
          "nix"
          "css"
          "html"
          "json"
          "javascript"
          "typescript"
          "lua"
          "markdown"
          "yaml"
          "toml"
          "xml"
          "bash"
          "sh"
        ];
        command = "setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab";
      }
      {
        # Enforce 4 spaces for Java, Kotlin, Python, C/C++, SQL
        event = ["FileType"];
        pattern = ["java" "kotlin" "python" "c" "cpp" "sql"];
        command = "setlocal shiftwidth=4 tabstop=4 softtabstop=4 expandtab";
      }
    ];

    languages = {
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      bash.enable = true;
      clang.enable = true;
      css.enable = true;
      html.enable = true;
      json.enable = true;
      typescript.enable = true;
      sql.enable = true;
      java.enable = true;
      kotlin.enable = true;
      lua.enable = true;
      markdown.enable = true;
      nix = {
        enable = true;
        lsp.servers = ["nixd"];
      };
      python.enable = true;
      yaml.enable = true;
      toml.enable = true;
      xml.enable = true;
      # docker.enable = true;
      env.enable = true;
      just.enable = true;
    };
    comments = {
      comment-nvim.enable = true;
    };
    lsp = {
      enable = true;

      formatOnSave = true;
      lspkind.enable = true;
      lightbulb.enable = true;
      lspsaga.enable = false;
      trouble.enable = true;
      lspSignature.enable = false;
      nvim-docs-view.enable = true;
    };

    extraPackages = with pkgs; [
      alejandra
      prettier
      shfmt
      ruff
    ];

    formatter.conform-nvim = {
      enable = true;

      setupOpts = {
        formatters_by_ft = {
          nix = ["alejandra"];
          markdown = ["prettier"];
          sh = ["shfmt"];
          bash = ["shfmt"];
          python = ["ruff_format"];
        };
      };
    };

    ui.smartcolumn = {
      enable = true;
      setupOpts = {
        disabled_filetypes = [
          "help"
          "text"
        ];
        custom_colorcolumn = {
          # this is a freeform module, it's `buftype = int;` for configuring column position
          nix = "110";
          java = "130";
          kotlin = "130";
          markdown = "80";
        };
      };
    };
  };
}
