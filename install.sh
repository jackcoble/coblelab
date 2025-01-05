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
ssh-keygen -q -t ed25519 -f "$ssh_dir/ssh_host_ed25519_key" -N "" -C ""
ssh-keygen -q -t ed25519 -f "$ssh_dir/ssh_boot_ed25519_key" -N "" -C ""

# Set the correct permissions on the SSH keys
chmod 600 "$ssh_dir/ssh_host_ed25519_key"
chmod 600 "$ssh_dir/ssh_boot_ed25519_key"

# Output the public keys to the console, as we need to manually update the SSH Public Keys module.
# Wait for the user to update the SSH Public Keys module before continuing.
echo "Host SSH Key: $(cat "$ssh_dir/ssh_host_ed25519_key.pub")"
echo "Boot SSH Key: $(cat "$ssh_dir/ssh_boot_ed25519_key.pub")"
echo "Update the SSH Public Keys module with the above keys, then press enter to continue."
read

# Convert the Host SSH Key into an Age public key.
# Prompt user to update .sops.yaml and reencrypt with the updated key
echo "Age Public Key: $(cat "$ssh_dir/ssh_host_ed25519_key.pub" | ssh-to-age)"
echo "Add this public key to .sops.yaml and re-encrypt the keys with: 'sops updatekeys secrets/secrets.yaml'"
echo "Press enter to continue."
read

# Install NixOS
nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --flake '.#nuc01' --target-host nixos@192.168.0.10 --build-on-remote