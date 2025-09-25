{myvars, ...}: {
  # Host-specific configuration
  networking.hostName = "mbair";
  networking.computerName = "mbair";

  # User configuration - host specific
  users.users."${myvars.username}" = {
    home = "/Users/${myvars.username}";
    description = myvars.username;
  };

  nix.settings.trusted-users = [myvars.username];

  # Host-specific settings can go here
  imports = [
    ./config.nix # Shared configuration
  ];

  # System configuration
  # Set this to the nix-darwin release version when you first installed this host
  # See: https://daiderd.com/nix-darwin/manual/index.html#opt-system.stateVersion
  system.stateVersion = 6;
}
