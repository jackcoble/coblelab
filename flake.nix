{
  description = "CobleLab NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    impermanence,
    sops-nix,
    nix-darwin,
    mac-app-util,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
  in {
    darwinConfigurations = {
      # MacBook Air
      mba01 = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ({pkgs, ...}: {
            nixpkgs.config.allowUnfree = true;
          })
          mac-app-util.darwinModules.default
          ./machines/mba01
        ];
      };
    };

    nixosConfigurations = {
      # ISO Builder
      iso01 = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {sshPublicKeys = import ./modules/nixos/ssh-public-keys.nix;};
        modules = [
          (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
          ./machines/iso01
        ];
      };


      # NUC
      nuc01 = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {sshPublicKeys = import ./modules/nixos/ssh-public-keys.nix;};
        modules = [
          ({pkgs, ...}: {
            nixpkgs.config.allowUnfree = true; # Add this line
          })
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
          ./machines/nuc01
        ];
      };
    };
  };
}
