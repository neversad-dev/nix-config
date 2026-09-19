{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.git;
in {
  config = mkIf cfg.enable {
    # Remove existing ~/.gitconfig to ensure git uses ~/.config/git/config
    home = {
      activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
        rm -f ~/.gitconfig
      '';

      packages = with pkgs; [
        git
        git-lfs
      ];

      sessionPath = [
        "${pkgs.git}/bin"
      ];
    };

    programs.git = {
      enable = true;
      lfs.enable = true;

      ignores = [
        ".DS_Store"
        ".AppleDouble"
        ".LSOverride"
        ".idea"
        ".vscode"
        ".direnv"
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

        log = {
          date = "iso"; # use iso format for date
        };

        interactive = {
          diffFilter = "delta --color-only";
          singlekey = true;
        };
      };
    };
  };
}
