# direnv + nix-direnv: auto-activate devShells when entering project directories
{
  config,
  lib,
  ...
}: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # caches devShells so re-entering dirs is instant
  };
}
