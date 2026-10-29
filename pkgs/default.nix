{pkgs, ...}: {
  herdr-nvim-nav = pkgs.callPackage ./herdr-nvim-nav.nix {};
  herdr-worktrunk = pkgs.callPackage ./herdr-worktrunk.nix {};
  # Vendored (only in nixpkgs unstable); built on 25.11's toolchain so the
  # binary runs on Android (glibc 2.40).
  tuxedo = pkgs.nixos2511.callPackage ./tuxedo.nix {};
  # Same, plus zig_0_16/installAgentSkills borrowed from unstable (25.11
  # has neither).
  herdr = pkgs.nixos2511.callPackage ./herdr.nix {
    inherit (pkgs.unstable) zig_0_16 installAgentSkills;
  };
}
