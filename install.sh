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
mkdir -p "$ssh_dir"

# Ask the user if they want to import an existing keys directory
read -p "Do you want to import an existing keys directory? (y/N): " import_keys
if [[ "$import_keys" =~ ^[Yy]$ ]]; then
  read -p "Enter the path to the keys directory (default: ./keys): " keys_dir

  keys_dir=${keys_dir:-./keys}
  keys_dir=$(realpath "$keys_dir")

  if [ -d "$keys_dir" ]; then
    cp -f "$keys_dir"/* "$ssh_dir/"
  else
    echo "The specified directory does not exist. Exiting."
    exit 1
  fi
else
  # Generate new keys
  ssh-keygen -q -t ed25519 -f "$ssh_dir/ssh_host_ed25519_key" -N "" -C ""
  ssh-keygen -q -t ed25519 -f "$ssh_dir/ssh_boot_ed25519_key" -N "" -C ""
fi

# Set the correct permissions on the SSH keys
chmod 600 "$ssh_dir/ssh_host_ed25519_key"
chmod 644 "$ssh_dir/ssh_host_ed25519_key.pub"
chmod 600 "$ssh_dir/ssh_boot_ed25519_key"
chmod 644 "$ssh_dir/ssh_boot_ed25519_key.pub"

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

# Ask the user for the Disk encryption key to set, confirm it twice
read -s -p "Enter the Disk Encryption Key: " disk_key
echo
read -s -p "Confirm the Disk Encryption Key: " disk_key_confirm
echo

if [ "$disk_key" != "$disk_key_confirm" ]; then
  echo "The keys do not match. Exiting."
  exit 1
fi

# Write the key to /tmp/secret.key (supplied to NixOS installation)
echo "$disk_key" > "/tmp/secret.key"

# Ask the user if they are reinstalling the machine.
# Sets the "disko mode" - mount disks or format them
read -p "Are you reinstalling the machine? (y/N): " disko_mode
if [[ "$disko_mode" =~ ^[Yy]$ ]]; then
  disko_mode="disko"
else
  disko_mode="mount"
fi

# Install NixOS
nix run github:nix-community/nixos-anywhere -- --debug --extra-files "$temp" --disk-encryption-keys /tmp/secret.key /tmp/secret.key  --disko-mode "$disko_mode" --flake '.#nuc01' --target-host nixos@192.168.0.10 --build-on-remote