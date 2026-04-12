{...}: let
  hostname = "mbair";
  primaryUser = "neversad";
in {
  # Host-specific configuration
  networking.hostName = hostname;
  networking.computerName = hostname;

  # User configuration - host specific
  users.users.${primaryUser} = {
    home = "/Users/${primaryUser}";
    description = primaryUser;
  };
  system.primaryUser = primaryUser;
  nix.settings.trusted-users = [primaryUser];

  # Host-specific settings can go here
  imports = [
    ./config.nix # Shared configuration
  ];

  # System configuration
  # Set this to the nix-darwin release version when you first installed this host
  # See: https://daiderd.com/nix-darwin/manual/index.html#opt-system.stateVersion
  system.stateVersion = 6;
}
