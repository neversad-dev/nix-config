{...}: {
  imports = [
    ../../android
  ];

  # Just(1) reads this to resolve the hostname.
  home.sessionVariables.HOSTNAME = "pixel6";

  # Home manager specific feature flags. Enable new ones only after testing
  # on device: unstable (glibc >= 2.42) TUIs don't run on Android.
  features = {
    ai.enable = false;
    theme.catppuccin.enable = true;
    cli = {
      neovim.enable = true; # language packages aliased in flake.nix
      git.enable = true;
      git.signing.enable = false;
      mitmproxy.enable = false;
      starship.enable = true;
      tldr.enable = false;
      atuin.enable = true;
      direnv.enable = true;
      eza.enable = true;
      fastfetch.enable = true;
      fastfetch.logo = "android";
      zoxide.enable = true;
      pay-respects.enable = false;
      herdr.enable = false; # vendored pkg exists (pkgs/herdr.nix) but zig
      # 0.16 build segfaults on-device (zig on Android/proot)
      btop.enable = false;
      superfile.enable = true;
      tuxedo.enable = true;
    };
    secrets.enable = false;
  };
}
