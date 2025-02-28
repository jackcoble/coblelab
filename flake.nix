{
  description = "CobleLab NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    impermanence,
    sops-nix,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
  in {
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
