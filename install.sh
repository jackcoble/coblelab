# !/usr/bin/env bash
# CobleLab NixOS Installation Script

# Create temporary directory
temp=$(mktemp -d)
mkdir -p $temp

# Function to cleanup temporary directory on exit
function cleanup {
  rm -rf $temp
}
trap cleanup EXIT

# Create the directory where the initrd SSH host keys will live
install -d -m 755 "$temp/etc/ssh/initrd"

# Generate the SSH host keys for the initrd
ssh-keygen -t ed25519 -f "$temp/etc/ssh/initrd/ssh_host_ed25519_key" -N "" -C ""

# Set the correct permissions on the SSH host keys
chmod 600 "$temp/etc/ssh/initrd/ssh_host_ed25519_key"

# Install NixOS
nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --flake '.#nuc01' --target-host root@192.168.0.10 --build-on-remote