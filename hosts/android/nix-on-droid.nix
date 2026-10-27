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
  # Constraints:
  #   - system.stateVersion and HM stateVersion must stay at 24.05
  #     to match the pinned nix-on-droid release (nixpkgs-24-05 and
  #     home-manager-24-05 in flake.nix).
  #   - We cherry-pick individual modules from home/features/cli instead
  #     of importing cli/default.nix wholesale, so we can add things
  #     incrementally and avoid features that don't build in proot.
  #   - Modules written for HM 24.11 (mbair) are shimmed through
  #     compat.nix so they evaluate on HM 24.05 without modification.
  #
  # Currently enabled: zsh, zoxide, fzf, fd, tree, git+delta+lazygit,
  #                    starship, atuin, eza, dust, fastfetch, tldr,
  #                    bat, htop, jq, yq, ripgrep, zip

  environment.packages = with pkgs; [
    git
    curl
    vim
  ];

  user.shell = lib.mkDefault "${pkgs.zsh}/bin/zsh";

  environment.etcBackupExtension = ".bak";
  system.stateVersion = "24.05";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

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
        ./compat.nix
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
        ../../home/features/cli/tldr.nix
      ];

      features.cli.git.enable = true;
      features.cli.starship.enable = true;
      features.cli.tldr.enable = true;

      programs.bat.enable = true;

      # HM-24.05 sometimes sources zsh-syntax-highlighting in an order
      # that conflicts with atuin's zle bindings. Re-source it last.
      programs.zsh.initExtra = ''
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
      # Copy a Nerd Font from the nix store on every activation so
      # Starship icons render correctly.
      home.activation.copyTermuxFont = lib.hm.dag.entryAfter ["writeBoundary"] ''
        fontStorePath="${pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }}/share/fonts/truetype/NerdFonts/JetBrainsMonoNerdFont-Regular.ttf"
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
