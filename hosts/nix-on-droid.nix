{
  config,
  lib,
  pkgs,
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
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    useUserPackages = true;

    config = {
      config,
      lib,
      pkgs,
      ...
    }: {
      # Minimal home-manager config to verify integration works.
      # Will be expanded later (shell, git, ssh, etc.).
      programs.bash.enable = true;

      # Must match the nix-on-droid release version
      home.stateVersion = "24.05";
    };
  };
}
