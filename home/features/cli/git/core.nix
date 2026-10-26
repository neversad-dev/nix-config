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
      activation.sshAllowedSigners = lib.hm.dag.entryAfter ["linkGeneration"] ''
        PUBKEY="$HOME/.ssh/id_ed25519.pub"
        if [ -f "$PUBKEY" ]; then
          ${pkgs.coreutils}/bin/printf '%s\t%s\n' \
            "7419136+neversad-dev@users.noreply.github.com" \
            "$(${pkgs.coreutils}/bin/cat "$PUBKEY")" \
            > "$HOME/.ssh/allowed_signers"
          ${pkgs.coreutils}/bin/chmod 600 "$HOME/.ssh/allowed_signers"
        fi
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
          signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        };

        core = {
          pager = "delta";
          whitespace = "trailing-space,space-before-tab";
          compression = 9;
          preloadindex = true;
        };

        commit = {
          gpgsign = true;
        };

        gpg = {
          format = "ssh";
          ssh = {
            allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
            program = "${pkgs.openssh}/bin/ssh-keygen";
          };
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
