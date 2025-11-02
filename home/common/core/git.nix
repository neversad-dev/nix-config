{
  lib,
  pkgs,
  ...
}: {
  # Remove existing ~/.gitconfig to ensure git uses ~/.config/git/config
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ~/.gitconfig
  '';

  home.packages = with pkgs; [
    git
    git-lfs
    delta # Modern diff viewer for Git
  ];

  home.sessionPath = [
    "${pkgs.git}/bin"
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;

    ignores = [
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      ".idea"
      ".vscode"
    ];

    includes = [
      {
        path = let
          catppuccin-delta = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "delta";
            rev = "e9e21cffd98787f1b59e6f6e42db599f9b8ab399";
            sha256 = "sha256-04po0A7bVMsmYdJcKL6oL39RlMLij1lRKvWl5AUXJ7Q=";
          };
        in "${catppuccin-delta}/catppuccin.gitconfig";
      }
    ];

    settings = {
      user = {
        name = "neversad-dev";
        email = "7419136+neversad-dev@users.noreply.github.com";
      };

      core = {
        pager = "delta";
        whitespace = "trailing-space,space-before-tab";
        compression = 9;
        preloadindex = true;
      };

      credential.helper = "osxkeychain";

      init.defaultBranch = "main";
      branch = {
        sort = "-committerdate";
      };
      tag = {
        sort = "-taggerdate";
      };

      push = {
        autoSetupRemote = true;
        default = "current";
        followTags = true;
      };
      pull = {
        default = "current";
        rebase = true;
      };

      rebase = {
        autoStash = true;
        missingCommitsCheck = "error";
      };

      merge = {
        conflictstyle = "zdiff3"; # Show common ancestor in merge conflicts
      };

      status = {
        branch = true;
        showStash = true;
        showUntrackedFiles = "all";
      };
      advice = {
        addEmptyPathspec = false;
        pushNonFastForward = false;
        statusHints = false;
      };

      diff = {
        context = 3;
        renames = "copies";
        interHunkContext = 10;
      };

      interactive = {
        diffFilter = "delta --color-only";
        singlekey = true;
      };

      delta = {
        enable = true;
        side-by-side = true;
        navigate = true;
        features = "catppuccin-mocha";
        line-numbers = true;
        whitespace-error-style = "22 reverse";
      };

      url = {
        "git@github.com:neversad-dev/" = {
          insteadOf = "nd:";
        };
        "git@github.com:" = {
          insteadOf = "gh:";
        };
        "ssh://git@github.com/neversad-dev" = {
          insteadOf = "https://github.com/neversad-dev";
        };
      };

      # signing = {
      #   key = "xxx";
      #   signByDefault = true;
      # };
    };
  };

  programs.zsh.shellAliases = {
    gs = "git status --short";
    gd = "git diff";
    gds = "git diff --staged";

    ga = "git add";
    gaa = "git add --all";
    gap = "git add --patch"; # y - stage; n - skip; s - split; e = edit

    gc = "git commit";
    gcm = "git commit -m";
    gca = "git commit --amend";

    gp = "git push";
    gu = "git pull";

    gl = "git log --graph --all --pretty=format:'%C(auto)%h %C(white) %an %ar %C(auto)%D%n%s%n' --abbrev-commit";
    gb = "git branch";

    gini = "git init";
    gcl = "git clone";
  };
}
