{
  mylib,
  myvars,
  ...
}: let
  hostname = "mbair";
  primaryUser = myvars.primaryUser;
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
    ./features.nix # Shared configuration
    (mylib.relativeToRoot "modules/darwin")
    (mylib.relativeToRoot "secrets/darwin.nix")
  ];
}
