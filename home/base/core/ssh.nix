# One-time setup (macOS):
#   ssh-add --apple-use-keychain ~/.ssh/id_ed25519
# This stores the passphrase in macOS Keychain. After the first unlock,
# AddKeysToAgent + UseKeychain in the config below handle everything automatically.
# On Linux (enduro), run `ssh-add ~/.ssh/id_ed25519` once per session or use a
# desktop keyring integration (e.g. GNOME Keyring / KDE Wallet) if available.
{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = [pkgs.openssh]; # ssh-keygen, ssh-add (not installed by programs.ssh)

  programs.ssh = {
    enable = true;

    # Don't merge with system defaults — we control everything.
    # Without this, Home Manager may produce duplicate Host * blocks.
    enableDefaultConfig = false;

    # macOS-specific directives that must sit outside Host blocks.
    # IgnoreUnknown prevents Linux ssh from erroring if it ever reads this file.
    extraConfig = lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
      IgnoreUnknown UseKeychain
      UseKeychain yes
    '';

    settings = {
      # Global defaults applied to all hosts (overridden per-host when needed).
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "yes";
        Compression = true;
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
        HashKnownHosts = true;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "auto";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "10m";
        IdentitiesOnly = true;
      };

      # GitHub — the host we interact with most frequently.
      # Uses the per-machine identity key (id_ed25519) per our single-key-per-host policy.
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
        PreferredAuthentications = "publickey";
      };
      # Future VPS: add host aliases here. Follow the same pattern as GitHub:
      #
      # "my-vps" = {
      #   HostName = "1.2.3.4";
      #   User = "neversad";
      #   IdentityFile = "~/.ssh/id_ed25519";
      #   Port = 22;
      # };
    };
  };

  # Idempotently seed GitHub's host key to prevent TOFU on first connect.
  # If DNS is ever poisoned or GitHub's key changes, SSH aborts instead of
  # silently accepting an attacker-controlled key.
  home.activation.sshKnownHosts = lib.hm.dag.entryAfter ["linkGeneration"] ''
    if [[ -v DRY_RUN ]]; then
      echo "[dry-run] would seed GitHub host key in $HOME/.ssh/known_hosts" >&2
    else
      mkdir -p "$HOME/.ssh"
      GH_KEY="github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
      if [ -f "$HOME/.ssh/known_hosts" ]; then
        if ! ${pkgs.gnugrep}/bin/grep -qF "$GH_KEY" "$HOME/.ssh/known_hosts" 2>/dev/null; then
          ${pkgs.coreutils}/bin/printf '%s\n' "$GH_KEY" >> "$HOME/.ssh/known_hosts"
        fi
      else
        ${pkgs.coreutils}/bin/printf '%s\n' "$GH_KEY" > "$HOME/.ssh/known_hosts"
      fi
      ${pkgs.coreutils}/bin/chmod 600 "$HOME/.ssh/known_hosts"
    fi
  '';

  # Bootstrap safety check: warn if the per-machine SSH key is missing.
  # Agenix decryption, GitHub auth, and commit signing all depend on it.
  home.activation.checkSshKey = lib.hm.dag.entryAfter ["linkGeneration"] ''
    if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
      ${pkgs.coreutils}/bin/printf '\n\033[1;33mWARNING:\033[0m No ~/.ssh/id_ed25519 found.\n' >&2
      ${pkgs.coreutils}/bin/printf '  Run:  ssh-keygen -t ed25519 -a 256 -C "${config.home.username}@$(hostname)" -f ~/.ssh/id_ed25519\n' >&2
      ${pkgs.coreutils}/bin/printf '  Then: ssh-add${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin " --apple-use-keychain"} ~/.ssh/id_ed25519\n' >&2
      ${pkgs.coreutils}/bin/printf '  And:  cat ~/.ssh/id_ed25519.pub → GitHub SSH settings\n\n' >&2
    fi
  '';
}
