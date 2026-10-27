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
    # Pass shared libraries and flake inputs into home-manager scope
    # so existing mbair modules can be reused.
    extraSpecialArgs = {
      inherit inputs mylib myvars agenix;
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
        ../../home/features/cli/btop.nix
        ../../home/features/cli/tree.nix
        ../../home/features/cli/git/default.nix
        ../../home/features/cli/starship.nix
        ../../home/neversad/fonts.nix
      ];

      # Enable the feature-flagged CLI modules we want on this device.
      features.cli.git.enable = true;
      features.cli.starship.enable = true;

      # home.nix sets EDITOR=nvim; install bat since the default
      # cli/default.nix which provides it is not imported here yet.
      programs.bat.enable = true;

      # Handy baseline packages not yet brought in by imported modules.
      home.packages = with pkgs; [
        htop
        jq
        yq
        ripgrep
        zip
        python3
      ];

      # Install fonts via fontconfig so they land in ~/.local/share/fonts.
      fonts.fontconfig.enable = true;

      # Termux-based terminals read a single font from ~/.termux/font.ttf.
      # Link Maple Mono NF Regular so icons/glyphs render for starship etc.
      home.file.".termux/font.ttf".source =
        "${pkgs.maple-mono.NF-unhinted}/share/fonts/truetype/MapleMono-NF-Regular.ttf";

      # Force nix-on-droid compatible state version irrespective of
      # the value coming from shared home.nix (24.11).
      home.stateVersion = lib.mkForce "24.05";

      # Minimal baseline kept from the initial bootstrap.
      programs.bash.enable = true;
    };
  };
}
