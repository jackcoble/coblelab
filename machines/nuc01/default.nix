{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  # Disks.
  coblelab.disks.enable = true;
  coblelab.disks.systemd-boot = true;
  coblelab.disks.btrfs.enable = true;

  # Networking.
  networking.networkmanager.enable = true;
  networking.hostName = "nuc01";

  # SSH.
  coblelab.ssh.enable = true;

  # Users.
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBt423fvkSC8SeKVPPAl3MFpwvzwBZ8XEBd4/KrINoP"
  ];

  # Timezone.
  coblelab.timezone.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
