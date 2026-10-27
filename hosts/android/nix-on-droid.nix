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
  # Version must stay at 24.05 to match the nix-on-droid release
  # (nixpkgs-24-05 and home-manager-24-05 are pinned in flake.nix).

  environment.packages = with pkgs; [
    git
    curl
    vim
  ];

  # Make zsh the login shell for the nix-on-droid user.
  # This is what the app spawns on launch (instead of bash).
  user.shell = lib.mkDefault "${pkgs.zsh}/bin/zsh";

  # Backup etc files instead of failing if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Must match the nix-on-droid release version
  system.stateVersion = "24.05";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Built-in home-manager (via nix-on-droid module).
  # This is separate from the flake's standalone homeConfigurations.
  home-manager = {
    # Pass shared libraries into home-manager scope so existing mbair
    # modules can be reused.  Note: `inputs` is intentionally omitted
    # because nix-on-droid HM-24.05 does not forward it correctly;
    # modules that need flake inputs should declare their own stubs.
    extraSpecialArgs = {
      inherit mylib myvars agenix;
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
      ];

      # Enable the feature-flagged CLI modules we want on this device.
      features.cli.git.enable = true;
      features.cli.starship.enable = true;

      # home.nix sets EDITOR=nvim; install bat since the default
      # cli/default.nix which provides it is not imported here yet.
      programs.bat.enable = true;

      # Explicitly source zsh-syntax-highlighting after all other init.
      # HM-24.05 sometimes places it in the wrong order when combined
      # with atuin's zle widget wrappers, causing highlighting to fail.
      programs.zsh.initExtra = ''
        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      '';

      # Handy baseline packages not yet brought in by imported modules.
      home.packages = with pkgs; [
        htop
        jq
        yq
        ripgrep
        zip
        python3
      ];

      # Termux reads a real file from ~/.termux/font.ttf.
      # Symlinks to /nix/store don't resolve in the Android UI layer,
      # so we copy the font via activation instead.
      home.activation.copyTermuxFont = lib.hm.dag.entryAfter ["writeBoundary"] ''
        fontStorePath="${pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }}/share/fonts/truetype/NerdFonts/JetBrainsMonoNerdFont-Regular.ttf"
        targetDir="${config.home.homeDirectory}/.termux"
        mkdir -p "$targetDir"
        if [ -e "$fontStorePath" ]; then
          cp -f "$fontStorePath" "$targetDir/font.ttf"
        fi
      '';

      # Clean up stale colors.properties from an earlier generation.
      # Termux was reading a Catppuccin ANSI palette from this file that
      # made zsh syntax-highlighting colors invisible against the background.
      home.activation.removeStaleTermuxColors = lib.hm.dag.entryAfter ["writeBoundary"] ''
        stale="${config.home.homeDirectory}/.termux/colors.properties"
        if [ -f "$stale" ]; then
          rm -f "$stale"
        fi
      '';

      # Force nix-on-droid compatible state version irrespective of
      # the value coming from shared home.nix (24.11).
      home.stateVersion = lib.mkForce "24.05";

      # Minimal baseline kept from the initial bootstrap.
      programs.bash.enable = true;
    };
  };
}
