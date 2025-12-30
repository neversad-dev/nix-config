{
  pkgs,
  lib,
  ...
}: {
  # Nix instance is managed via Determinate installation

  nix = {
    enable = false;

    package = pkgs.nix;

    settings = {
      # enable flakes globally
      experimental-features = ["nix-command" "flakes"];

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;
    };
  };

  # Install home manager but it is managed separately
  environment.systemPackages = [
    pkgs.home-manager
  ];
}
