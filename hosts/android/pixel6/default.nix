{
  lib,
  pkgs,
  mylib,
  myvars,
  ...
}: {
  # Host-specific configuration
  # NOTE: networking.hostName is not available in nix-on-droid.
  # The hostname is set via Termux/Android system settings.
  environment.packages = with pkgs; [
    git
    curl
    vim
  ];
  user.shell = lib.mkDefault "${pkgs.zsh}/bin/zsh";
  time.timeZone = lib.mkDefault "Europe/Kyiv";
  environment.etcBackupExtension = ".bak";
  system.stateVersion = "24.05";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  imports = [
    ./secrets.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit mylib myvars;};
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    config = import (mylib.relativeToRoot "home/hosts/android/pixel6.nix");
  };
}
