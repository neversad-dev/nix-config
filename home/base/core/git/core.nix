{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  config = mkMerge [
    # The git package is unconditional: a bare git binary is always available,
    # independent of any feature flags.
    { programs.git.enable = true; }

    (mkIf config.features.cli.git.core.enable {
      home = {
        # Git reads ~/.gitconfig with higher priority than ~/.config/git/config,
        # so a stale ~/.gitconfig would shadow our HM-managed settings. Migrate
        # it to a one-time backup instead of deleting (preserves user config),
        # after writeBoundary and dry-run-aware so a preview never touches it.
        activation.migrateGitconfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          gitconfig="$HOME/.gitconfig"
          if [ -f "$gitconfig" ] && [ ! -L "$gitconfig" ]; then
            $DRY_RUN_CMD mv $VERBOSE_ARG "$gitconfig" "$gitconfig.pre-hm.bak"
          fi
        '';

        # git itself is installed by programs.git (respects programs.git.package).
        packages = [ pkgs.git-lfs ];

        sessionPath = [
          "${config.programs.git.package}/bin"
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

        settings =
          let
            isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
          in
          {
            user = {
              name = "neversad-dev";
              email = "7419136+neversad-dev@users.noreply.github.com";
            };

            core = {
              whitespace = "trailing-space,space-before-tab";
              compression = 9;
              preloadindex = true;
            };

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
              singlekey = true;
            };
          }
          // lib.optionalAttrs isDarwin {
            credential.helper = "osxkeychain";
          };
      };
    })
  ];
}
