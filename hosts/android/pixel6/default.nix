{
  lib,
  pkgs,
  mylib,
  myvars,
  inputs,
  outputs,
  ...
}: {
  # Host-specific configuration
  # NOTE: networking.hostName is not available in nix-on-droid.
  # The hostname is set via Termux/Android system settings.
  # No system-level packages: everything comes from Home Manager.
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
    extraSpecialArgs =
      inputs
      // {
        inherit outputs mylib myvars;
        isHm24 = true;
      };
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    config = import ../../../home/hosts/android/pixel6.nix;
  };
}
