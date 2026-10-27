{
  config,
  lib,
  pkgs,
  mylib,
  myvars,
  inputs,
  agenix,
  ...
}: {
  # Nix-on-Droid configuration for Pixel 6.
  #
  # NOTE: Uses nix-on-droid master (not a pinned release) and nixpkgs
  # unstable so latest packages are available. compat.nix is kept
  # as a safety net.
  #
  # Currently enabled: zsh, zoxide, fzf, fd, tree, git+delta+lazygit,
  #                    starship, atuin, eza, dust, fastfetch, direnv,
  #                    tuxedo, pay-respects, bat, htop, jq, yq, ripgrep, zip

  environment.packages = with pkgs; [
    git
    curl
    vim
  ];

  user.shell = lib.mkDefault "${pkgs.zsh}/bin/zsh";

  # Set system timezone for GNU coreutils, ls --full-time, etc.
  # Standard tzdata name; list of values: ls /nix/store/*-tzdata-*/share/zoneinfo
  time.timeZone = lib.mkDefault "Europe/Kyiv";

  environment.etcBackupExtension = ".bak";
  system.stateVersion = "24.05";

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://numtide.cachix.org"
      "https://devenv.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  home-manager = {
    extraSpecialArgs = {
      inherit mylib myvars agenix;
      # NOTE: `inputs` is intentionally NOT passed here because HM-24.05
      # built into nix-on-droid does not forward flake inputs correctly.
      # Any module that needs inputs must bring them in through other
      # means or get a stub in compat.nix.
    };

    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    useUserPackages = true;

    config = {
      config,
      lib,
      pkgs,
      ...
    }: {
      imports = [
        ../../home/neversad/home.nix
        ../../home/common/default.nix
        ../../home/features/cli/shell.nix
        ../../home/features/cli/zoxide.nix
        ../../home/features/cli/fzf.nix
        ../../home/features/cli/fd.nix
        ../../home/features/cli/tree.nix
        ../../home/features/cli/git/default.nix
        ../../home/features/cli/starship.nix
        ../../home/features/cli/atuin.nix
        ../../home/features/cli/eza.nix
        ../../home/features/cli/dust.nix
        ../../home/features/cli/fastfetch.nix
        ../../home/features/development/direnv.nix
        ../../home/features/cli/tuxedo/default.nix
        ../../home/features/cli/pay-respects.nix
        ../../home/neversad/fonts.nix

      ];

      features.cli.git.enable = true;
      features.cli.starship.enable = true;

      programs.bat.enable = true;

      # Starship's background git checks can time out on Android's slow
      # shared storage. Increase the timeout so the prompt doesn't warn.
      programs.starship.settings.command_timeout = 2000;

      # Re-source zsh-syntax-highlighting after all other init so it
      # wraps atuin's widgets correctly and highlighting works.
      programs.zsh.initContent = ''
        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      '';

      home.packages = with pkgs; [
        htop
        jq
        yq
        ripgrep
        zip
        python3
      ];

      # Termux reads a real (non-symlink) file from ~/.termux/font.ttf.
      # Copy the same Maple Mono NF font used on mbair so icons render.
      home.activation.copyTermuxFont = lib.hm.dag.entryAfter ["writeBoundary"] ''
        fontStorePath="${pkgs.maple-mono.NF-unhinted}/share/fonts/truetype/MapleMono-NF-Regular.ttf"
        targetDir="${config.home.homeDirectory}/.termux"
        mkdir -p "$targetDir"
        if [ -e "$fontStorePath" ]; then
          cp -f "$fontStorePath" "$targetDir/font.ttf"
        fi
      '';

      # Remove a stale Catppuccin ANSI palette that was written by an
      # earlier generation. That palette made zsh syntax-highlighting
      # invisible on some backgrounds.
      home.activation.removeStaleTermuxColors = lib.hm.dag.entryAfter ["writeBoundary"] ''
        stale="${config.home.homeDirectory}/.termux/colors.properties"
        if [ -f "$stale" ]; then
          rm -f "$stale"
        fi
      '';

      home.stateVersion = lib.mkForce "24.05";
      programs.bash.enable = true;
    };
  };
}
