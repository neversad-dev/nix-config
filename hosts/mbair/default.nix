{
  mylib,
  myvars,
  inputs,
  outputs,
  ...
}: let
  hostname = "mbair";
  primaryUser = myvars.primaryUser;
in {
  # Host-specific configuration
  networking.hostName = hostname;
  networking.localHostName = hostname;
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
    ./secrets.nix
    (mylib.relativeToRoot "modules/darwin")
    (mylib.relativeToRoot "secrets/darwin.nix")
    inputs.home-manager.darwinModules.home-manager
  ];

  # Home Manager embedded into nix-darwin
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "home-manager.backup";
    extraSpecialArgs =
      inputs
      // {
        inherit outputs mylib myvars;
        isHm24 = false;
      };
    users.${primaryUser} = mylib.relativeToRoot "home/hosts/darwin/mbair.nix";
  };
}
