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
    # Take these HM packages from nixos-25.11 (newer, still glibc 2.40 so
    # TUIs work on Android). HM-scoped: nix-on-droid's own pkgs untouched.
    # Leaf packages only: overriding widely-depended-on ones (git, fzf)
    # here rebuilds their dependents from source; those are set via
    # programs.<x>.package in home/android/default.nix instead.
    sharedModules = [
      {
        _module.args.pkgs = pkgs.extend (_final: prev: {
          inherit
            (prev.nixos2511)
            atuin
            bat
            delta
            direnv
            eza
            fastfetch
            lazygit
            starship
            ;
        });
      }
    ];
    config = import ../../../home/hosts/android/pixel6.nix;
  };
}
