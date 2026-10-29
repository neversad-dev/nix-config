{
  lib,
  pkgs,
  mylib,
  myvars,
  ...
}: let
  hostname = "pixel6";
in {
  # Host-specific configuration
  networking.hostName = hostname;

  # System layer only; the user configuration lives under home/hosts/android.
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
    config = import ../../home/hosts/android/pixel6.nix;
  };
}
