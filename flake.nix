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
    # Last release on glibc < 2.42 (no TCGETS2, which Android SELinux blocks
    # on ttys). Source of newer TUI packages for nix-on-droid.
    nixpkgs-25-11.url = "github:NixOS/nixpkgs/nixos-25.11";

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
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-24-05";
      inputs.home-manager.follows = "home-manager-24-05";
    };

    # agenix.url = "github:ryantm/agenix";
    agenix.url = "github:yaxitech/ragenix"; # a rust implementation of agenix

    # Neovim framework; config lives in home/base/tui/neovim
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    # my private secrets, it's a private repository.
    # use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone to save time
    nix-secrets = {
      url = "git+ssh://git@github.com/neversad-dev/nix-secrets.git?shallow=1";
      flake = false;
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
    nvf,
    ...
  } @ inputs: let
    inherit (self) outputs;
    inherit (inputs.nixpkgs) lib;
    # Library functions, vendored locally from github:neversad-dev/nix-lib
    mylib =
      import ./lib {inherit lib;}
      // {
        relativeToRoot = lib.path.append ./.;
      };
    myvars = import ./vars;

    specialArgs =
      inputs
      // {
        inherit inputs outputs mylib myvars;
        isHm24 = false; # HM 24.05 hosts (nix-on-droid) override this
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

    # Neovim built from the in-repo nvf modules (home/base/tui/neovim).
    # scanPaths picks up the nvf modules and skips default.nix (the HM module).
    neovimFor = system:
      (nvf.lib.neovimConfiguration {
        pkgs = pkgsFor system;
        modules = mylib.scanPaths ./home/base/tui/neovim;
        extraSpecialArgs = {inherit mylib;};
      }).neovim;
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

    # nix-on-droid (release-24.05) and its HM run fully on nixpkgs-24.05.
    # Unstable binaries break on Android: glibc >= 2.42 uses the TCGETS2
    # ioctl, which Android's SELinux blocks on ttys (no prompt/TUI, stty
    # "Permission denied"). Opt in per package via pkgs.unstable.<name>,
    # only for non-interactive CLI tools.
    nixOnDroidConfigurations.pixel6 = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      pkgs = import nixpkgs-24-05 {
        system = "aarch64-linux";
        overlays = [
          overlays.additions
          overlays.unstable-packages
          overlays.nixos-25-11-packages
          # nvf's language presets reference these; missing in 24.05.
          # Leaf packages, so aliasing them doesn't force rebuilds.
          (final: prev: {
            inherit
              (prev.nixos2511)
              bash-language-server
              prettier
              superhtml
              tombi
              basedpyright
              just-lsp
              typescript-language-server
              # superfile from 25.11: newer than 24.05's 1.1.2, still glibc 2.40
              superfile
              # not in 24.05 at all; leaf packages, so no rebuild cascade
              pay-respects
              # 24.05's binaries are broken upstream/in proot (tealdeer 1.6.1
              # can't unpack the tldr pages zip, btop 1.3.2 can't parse
              # /proc/stat); retest with newer builds.
              tealdeer
              btop
              ;
            # Unstable TUIs that work on-device despite glibc >= 2.42.
            # Same derivations as the desktops/devShell: fetched from cache.
            inherit (prev.unstable) tuxedo herdr worktrunk;
          })
        ];
      };
      extraSpecialArgs = specialArgs;
      modules = [
        ./hosts/android/pixel6
      ];
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
            ./home/hosts/darwin/mbair.nix
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
            ./home/hosts/linux/enduro.nix
          ];
        };
    };

    # Standalone Neovim package: `nix run github:neversad-dev/nix-config`
    # (or `.#nvim` / `.#default` explicitly)
    packages = forAllSystems (system: {
      default = neovimFor system;
      nvim = neovimFor system;
    });

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
          tuxedo # project TODO manager (todo.txt, see Justfile)
        ];
        shellHook = ''
          export NH_FLAKE="."       # used by nh as the default flake path
          export NH_NO_CHECKS="1"   # nix-community/nh#305
        '';
      };
    });
  };
}
