{agenix, ...}: {
  imports = [
    agenix.darwinModules.default
  ];

  # Enable logs for debugging
  launchd.daemons."activate-agenix".serviceConfig = {
    StandardErrorPath = "/Library/Logs/org.nixos.activate-agenix.stderr.log";
    StandardOutPath = "/Library/Logs/org.nixos.activate-agenix.stdout.log";
  };

  # Default identity path for all Darwin machines
  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
  ];
}
