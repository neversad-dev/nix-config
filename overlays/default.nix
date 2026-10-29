{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # Expose the stable nixpkgs branch as `pkgs.stable` so individual
  # packages can be pinned when needed regardless of the default channel.
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # Expose nixpkgs-unstable as `pkgs.unstable` for hosts whose default
  # channel is older (nix-on-droid on 24.05) to opt individual packages in.
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # Expose nixos-25.11 as `pkgs.nixos2511`: newer than 24.05 but still on
  # glibc 2.40, so its interactive/TUI binaries work on Android (unlike
  # unstable's glibc >= 2.42, whose TCGETS2 ioctl SELinux blocks).
  nixos-25-11-packages = final: _prev: {
    nixos2511 = import inputs.nixpkgs-25-11 {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # nix-on-droid only: packages that exist only in nixpkgs unstable, vendored
  # and built on 25.11's toolchain so the binaries run on Android (glibc 2.40).
  # Kept out of `additions` so desktops keep the cached unstable builds.
  # Requires the unstable-packages and nixos-25-11-packages overlays.
  android-packages = final: _prev: {
    tuxedo = final.nixos2511.callPackage ../pkgs/tuxedo.nix {};
    # zig_0_16/installAgentSkills borrowed from unstable (25.11 has neither).
    herdr = final.nixos2511.callPackage ../pkgs/herdr.nix {
      inherit (final.unstable) zig_0_16 installAgentSkills;
    };
  };
}
