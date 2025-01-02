{
  description = "CobleLab NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    disko,
    nixpkgs,
  } @ inputs: let
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      # ISO Builder
      iso01 = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
          ./machines/iso01
        ];
      };

      # NUC
      nuc01 = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./machines/nuc01
        ];
      };
    };
  };
}
