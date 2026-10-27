{
  config,
  lib,
  pkgs,
  mylib,
  myvars,
  inputs,
  agenix,
  ...
}: {
  # Nix-on-Droid configuration for Pixel 6.
  # Version must stay at 24.05 to match the nix-on-droid release
  # (nixpkgs-24-05 and home-manager-24-05 are pinned in flake.nix).

  environment.packages = with pkgs; [
    git
    curl
    vim
  ];

  # Backup etc files instead of failing if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Must match the nix-on-droid release version
  system.stateVersion = "24.05";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Built-in home-manager (via nix-on-droid module).
  # This is separate from the flake's standalone homeConfigurations.
  home-manager = {
    # Pass shared libraries and flake inputs into home-manager scope
    # so existing mbair modules can be reused.
    extraSpecialArgs = {
      inherit inputs mylib myvars agenix;
    };

    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    useUserPackages = true;

    config = {
      config,
      lib,
      pkgs,
      ...
    }: {
      imports = [
        ../home/neversad/home.nix
        ../home/common/default.nix
      ];

      # Force nix-on-droid compatible state version irrespective of
      # the value coming from shared home.nix (24.11).
      home.stateVersion = lib.mkForce "24.05";

      # Minimal baseline kept from the initial bootstrap.
      programs.bash.enable = true;
    };
  };
}
