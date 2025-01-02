# CobleLab

My NixOS configuration.

## Remote Installation (via nixos-anywhere)

```
nix run github:nix-community/nixos-anywhere -- --flake '.#nuc01' --target-host nixos@192.168.0.10 --build-on-remote
```
