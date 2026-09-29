{
  lib,
  mylib,
  pkgs,
  ...
}: {
  imports = [
    (mylib.relativeToRoot "vars/features.nix")
    (mylib.relativeToRoot "vars/fonts.nix")
  ];

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };
  };
}
