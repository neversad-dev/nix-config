{
  config,
  lib,
  pkgs,
  mylib,
  myvars,
  ...
}: {
  imports = [
    (mylib.relativeToRoot "vars/features.nix")
    (mylib.relativeToRoot "vars/fonts.nix")
  ];

  home = {
    username = lib.mkDefault myvars.primaryUser;
    homeDirectory = lib.mkDefault (
      if pkgs.stdenv.hostPlatform.isDarwin
      then "/Users/${config.home.username}"
      else "/home/${config.home.username}"
    );
    # Compatibility baseline, not the installed Home Manager version.
    stateVersion = lib.mkDefault "24.11";
    packages = [pkgs.vim];
    sessionVariables = {
      EDITOR = lib.mkDefault "vim";
      VISUAL = lib.mkDefault "vim";
    };
  };
  programs.home-manager.enable = true;
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };
  };
}
