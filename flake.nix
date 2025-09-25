{
  description = "Public nix-darwin and home-manager configuration";

  # Flake-level nix configuration for faster builds
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://numtide.cachix.org"
      "https://devenv.cachix.org"
    ];

    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];

    http-connections = 128;
    max-substitution-jobs = 128;
    # Use shallow clones for large repositories
    fetch-git-shallow = true;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # theme
    catppuccin.url = "github:catppuccin/nix";
    catppuccin-vsc = {
      url = "https://flakehub.com/f/catppuccin/vscode/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # terminal
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Custom nvf configuration
    nvf-config.url = "github:neversad-dev/nvf-config";

    # my wallpapers
    wallpapers = {
      url = "github:neversad-dev/wallpapers";
      flake = false;
    };
  };

  outputs = inputs @ {
    nix-darwin,
    nixpkgs,
    home-manager,
    wallpapers,
    ghostty,
    nvf-config,
    ...
  }: let
    inherit (inputs.nixpkgs) lib;
    mylib = import ./lib {inherit lib;};
    myvars = import ./vars;

    specialArgs =
      inputs
      // {
        inherit myvars mylib;
      };

    darwinSystems = {
      aarch64 = "aarch64-darwin";
    };
    linuxSystems = {
      x86_64 = "x86_64-linux";
      aarch64 = "aarch64-linux";
    };

    allSystems = builtins.attrValues darwinSystems ++ builtins.attrValues linuxSystems;
    forAllSystems = func: (nixpkgs.lib.genAttrs allSystems func);
  in {
    # Export modules for use in other flakes
    darwinModules = {
      default = ./modules/darwin;
    };

    homeModules = {
      darwin = ./home/darwin;
      linux = ./home/linux;
    };

    # Export lib and vars for reuse
    lib = mylib;
    vars = myvars;

    # Example configurations (can be used directly or as templates)
    darwinConfigurations = {
      mbair = nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        system = darwinSystems.aarch64;
        modules = [
          ./modules/darwin
          ./hosts/mbair
        ];
      };
    };

    homeConfigurations = {
      "${myvars.username}@mbair" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${darwinSystems.aarch64};
        extraSpecialArgs = specialArgs // {inherit wallpapers inputs;};
        modules = [
          ./home/darwin
          ./hosts/mbair/home.nix
          {home.packages = [nvf-config.packages.${darwinSystems.aarch64}.default];}
        ];
      };

      "${myvars.username}@tinkerdell" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${linuxSystems.x86_64};
        extraSpecialArgs = specialArgs // {inherit wallpapers inputs;};
        modules = [
          ./home/linux
          ./hosts/tinkerdell/home.nix
          {home.packages = [nvf-config.packages.${linuxSystems.x86_64}.default];}
        ];
      };

      "${myvars.username}@enduro" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${linuxSystems.x86_64};
        extraSpecialArgs = specialArgs // {inherit wallpapers inputs;};
        modules = [
          ./home/linux
          ./hosts/enduro/home.nix
          {home.packages = [nvf-config.packages.${linuxSystems.x86_64}.default];}
        ];
      };
    };

    # standalone neovim package for each system
    packages = forAllSystems (system: {
      nvim = nvf-config.packages.${system}.default;
    });

    # Format the nix code in this flake
    formatter = forAllSystems (
      system: nixpkgs.legacyPackages.${system}.alejandra
    );
  };
}
