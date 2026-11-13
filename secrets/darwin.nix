{
  agenix,
  nix-secrets,
  myvars,
  ...
}: {
  imports = [
    agenix.darwinModules.default
  ];

  # Enable logs for debugging
  launchd.daemons."activate-agenix".serviceConfig = {
    StandardErrorPath = "/Library/Logs/org.nixos.activate-agenix.stderr.log";
    StandardOutPath = "/Library/Logs/org.nixos.activate-agenix.stdout.log";
  };

  # Default identity path for all Darwin machines.
  # Generate this key manually if missing:
  #   sudo ssh-keygen -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key -C "root@$(hostname)"
  age = {
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    secrets = {
      "github-cli" = {
        file = "${nix-secrets}/shared/github-cli.age";
        mode = "0400";
        owner = myvars.primaryUser;
      };
      "openrouter-codecompanion" = {
        file = "${nix-secrets}/shared/openrouter-codecompanion.age";
        mode = "0400";
        owner = myvars.primaryUser;
      };
      "openrouter-pi" = {
        file = "${nix-secrets}/shared/openrouter-pi.age";
        mode = "0500";
        owner = myvars.primaryUser;
      };
    };
  };
}
