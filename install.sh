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

# Create some SSH Host and Boot keys
# Host keys are for the sshd server, and eventually secrets encryption for the machine
# Boot keys are for the initrd. This is unencrypted, so we use a different keypair
ssh_dir="$temp/persist/etc/ssh"
install -d -m 755 "$ssh_dir"
ssh-keygen -t ed25519 -f "$ssh_dir/ssh_host_ed25519_key" -N "" -C ""
ssh-keygen -t ed25519 -f "$ssh_dir/persist/etc/ssh/ssh_boot_ed25519_key" -N "" -C ""

# Set the correct permissions on the SSH keys
chmod 600 "$ssh_dir/ssh_host_ed25519_key"
chmod 600 "$ssh_dir/ssh_boot_ed25519_key"

# Install NixOS
nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --flake '.#nuc01' --target-host nixos@192.168.0.10 --build-on-remote