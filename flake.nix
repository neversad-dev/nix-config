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

    # agenix.url = "github:ryantm/agenix";
    agenix.url = "github:yaxitech/ragenix"; # a rust implementation of agenix

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

    ########################  My own repositories  #########################################

    # Shared library functions
    nix-lib = {
      url = "github:neversad-dev/nix-lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # my private secrets, it's a private repository.
    # use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone to save time
    mysecrets = {
      url = "git+ssh://git@github.com/neversad-dev/nix-secrets.git?shallow=1";
      flake = false;
    };

    # Custom nvf configuration
    nvf-config = {
      url = "github:neversad-dev/nvf-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # my wallpapers
    wallpapers = {
      url = "github:neversad-dev/wallpapers";
      flake = false;
    };
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    agenix,
    home-manager,
    wallpapers,
    ghostty,
    nvf-config,
    nix-lib,
    ...
  } @ inputs: let
    inherit (self) outputs;
    inherit (inputs.nixpkgs) lib;
    mylib =
      nix-lib.lib
      // {
        relativeToRoot = lib.path.append ./.;
      };
    myvars = import ./vars;

    specialArgs =
      inputs
      // {
        inherit mylib myvars;
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
    # Configure nixpkgs with allowUnfree and fetcherVersion for packages output
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          fetcherVersion = 7;
        };
      };
  in {
    # Export modules for use in other flakes
    darwinModules = {
      default = ./modules/darwin;
    };

    homeModules = {
      darwin = ./home/export/darwin;
      linux = ./home/export/linux;
    };

    # Export lib and myvars for reuse
    lib = mylib;
    myvars = myvars;

    # Example configurations (can be used directly or as templates)
    darwinConfigurations = {
      mbair = nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        system = darwinSystems.aarch64;
        modules = [
          ./hosts/mbair
        ];
      };
    };

    homeConfigurations = {
      "${myvars.primaryUser}@mbair" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor darwinSystems.aarch64;
        extraSpecialArgs = specialArgs // {inherit outputs wallpapers inputs;};
        modules = [
          ./home/${myvars.primaryUser}/mbair.nix
        ];
      };

      "${myvars.primaryUser}@enduro" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor linuxSystems.x86_64;
        extraSpecialArgs = specialArgs // {inherit outputs wallpapers inputs;};
        modules = [
          ./home/${myvars.primaryUser}/enduro.nix
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
