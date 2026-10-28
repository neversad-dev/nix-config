{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.git;
in {
  config = mkIf (cfg.enable && cfg.signing.enable) {
    home.activation.sshAllowedSigners = lib.hm.dag.entryAfter ["linkGeneration"] ''
      PUBKEY="$HOME/.ssh/id_ed25519.pub"
      if [ -f "$PUBKEY" ]; then
        if [[ -v DRY_RUN ]]; then
          echo "[dry-run] would update $HOME/.ssh/allowed_signers" >&2
        else
          ${pkgs.coreutils}/bin/printf '%s\t%s\n' \
            "7419136+neversad-dev@users.noreply.github.com" \
            "$(${pkgs.coreutils}/bin/cat "$PUBKEY")" \
            > "$HOME/.ssh/allowed_signers"
          ${pkgs.coreutils}/bin/chmod 600 "$HOME/.ssh/allowed_signers"
        fi
      fi
    '';

    programs.git.settings = {
      commit.gpgsign = true;

      gpg = {
        format = "ssh";
        ssh = {
          allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
          program = "${pkgs.openssh}/bin/ssh-keygen";
        };
      };

      user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
    };
  };
}
