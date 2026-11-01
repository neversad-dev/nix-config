# direnv + nix-direnv: auto-activate devShells when entering project directories
{
  config,
  lib,
  ...
}: {
  options.features.cli.direnv.enable = lib.mkEnableOption "direnv with nix-direnv";

  config = lib.mkIf config.features.cli.direnv.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true; # caches devShells so re-entering dirs is instant
    };
  };
}
