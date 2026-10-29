{
  lib,
  pkgs,
  mylib,
  myvars,
  inputs,
  outputs,
  pkgsUnstable,
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
    extraSpecialArgs =
      inputs
      // {
        inherit outputs mylib myvars;
        isHm24 = true;
      };
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    # HM 24.05 sets `_module.args.pkgs = mkDefault <droid pkgs>`; override it
    # so all HM packages come from unstable.
    sharedModules = [{_module.args.pkgs = pkgsUnstable;}];
    config = import ../../../home/hosts/android/pixel6.nix;
  };
}
