# Home Manager compatibility polyfill.
# This module used to declare stubs for HM 24.05, but nix-on-droid
# master now bundles a newer HM. If any shared mbair module still
# needs a forward-declaration, add it here.
{ lib, ... }:

{
  # Stub for the custom worktrunk HM module (not part of nixpkgs).
  # git/worktrunk.nix references this; the stub is a no-op on Android
  # since the package isn't installed anyway.
  options.programs.worktrunk = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkOption { type = lib.types.bool; default = false; };
        enableZshIntegration = lib.mkOption { type = lib.types.bool; default = false; };
        settings = lib.mkOption { type = lib.types.anything; default = { }; };
      };
    };
    default = { };
  };
}
