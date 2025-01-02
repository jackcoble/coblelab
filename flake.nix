{
  description = "CobleLab";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
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
          ./machines/nuc01
        ];
      };
    };
  };
}
