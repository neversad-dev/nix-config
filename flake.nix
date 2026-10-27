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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-24-05.url = "github:NixOS/nixpkgs/nixos-24.05";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-24-05 = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-24-05";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/prerelease-25.11";
    };

    # agenix.url = "github:ryantm/agenix";
    agenix.url = "github:yaxitech/ragenix"; # a rust implementation of agenix

    # theme
    catppuccin.url = "github:catppuccin/nix";
    catppuccin-vsc = {
      url = "https://flakehub.com/f/catppuccin/vscode/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin-pi = {
      url = "github:otahontas/pi-coding-agent-catppuccin";
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
    nix-secrets = {
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
    nixpkgs-stable,
    nixpkgs-24-05,
    home-manager,
    wallpapers,
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
        inherit outputs mylib myvars;
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
    overlays = import ./overlays {inherit inputs;};

    # Configure nixpkgs with allowUnfree and fetcherVersion for packages output
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        overlays = [
          overlays.additions
          overlays.modifications
          overlays.stable-packages
        ];
        config = {
          allowUnfree = true;
          fetcherVersion = 7;
        };
      };
  in {
    # Example configurations (can be used directly or as templates)
    darwinConfigurations = {
      mbair = let
        system = darwinSystems.aarch64;
      in
        nix-darwin.lib.darwinSystem {
          inherit system specialArgs;
          pkgs = pkgsFor system;
          modules = [
            ./hosts/mbair
          ];
        };
    };

    homeConfigurations = {
      "${myvars.primaryUser}@mbair" = let
        system = darwinSystems.aarch64;
      in
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          extraSpecialArgs =
            specialArgs
            // {
              inherit outputs wallpapers inputs;
            };
          modules = [
            ./home/${myvars.primaryUser}/mbair.nix
          ];
        };

      "${myvars.primaryUser}@enduro" = let
        system = linuxSystems.x86_64;
      in
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          extraSpecialArgs =
            specialArgs
            // {
              inherit outputs wallpapers inputs;
            };
          modules = [
            ./home/${myvars.primaryUser}/enduro.nix
          ];
        };
    };

    nixOnDroidConfigurations.pixel6 = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      # NOTE: We use unstable nixpkgs here (not 24.05) so latest
      # packages (tuxedo, pay-respects, newer git, etc.) are available
      # with full binary cache coverage. The nix-on-droid module itself
      # is still release-24.05; this is an unsupported combination.
      pkgs = pkgsFor "aarch64-linux";
      extraSpecialArgs = specialArgs;
      modules = [
        ./hosts/android/nix-on-droid.nix
      ];
    };

    # Format the nix code in this flake
    formatter = forAllSystems (
      system: nixpkgs.legacyPackages.${system}.alejandra
    );

    # Dev shell for working on this nix config
    # Packages here are only needed during nix-config development, not system-wide
    # Usage: `nix develop`
    devShells = forAllSystems (system: let
      pkgs = pkgsFor system;
    in {
      default = pkgs.mkShell {
        name = "nix-config";
        packages = with pkgs; [
          nh # nix helper (darwin/home switch, clean, etc.)
          alejandra # nix formatter
          prettier # markdown/yaml/json formatter
          shfmt # shell script formatter
          taplo # toml formatter
          nix-melt # TUI flake.lock viewer
          nix-tree # TUI dependency graph for a derivation
          just # command runner (repo Justfile)
          tuxedo # project TODO manager (todo.txt)
        ];
        shellHook = ''
          export NH_FLAKE="."       # used by nh as the default flake path
          export NH_NO_CHECKS="1"   # nix-community/nh#305
        '';
      };
    });
  };
}
