{pkgs, ...}: {
  herdr-nvim-nav = pkgs.callPackage ./herdr-nvim-nav.nix {};
  herdr-worktrunk = pkgs.callPackage ./herdr-worktrunk.nix {};
}
