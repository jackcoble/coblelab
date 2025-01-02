default:
  just --list

# Installs a new system with the machine and target IP
install machine ip='':
  nix run github:nix-community/nixos-anywhere -- --flake '.#{{machine}}' --target-host nixos@{{ip}} --build-on-remote

# Creates a minimal x86_64-linux ISO with my SSH key
build-iso:
  nix build .#nixosConfigurations.iso01.config.system.build.isoImage