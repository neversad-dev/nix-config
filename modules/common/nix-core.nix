{
  pkgs,
  outputs,
  ...
}: {
  nix = {
    package = pkgs.nix;

    settings = {
      # enable flakes globally
      experimental-features = ["nix-command" "flakes"];
    };
  };

  # Allow unfree packages
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      # outputs.overlays.stable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];

    config.allowUnfree = true;
  };
  # Install home manager but it is managed separately
  environment.systemPackages = [
    pkgs.home-manager
  ];
}
