{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
    ../../modules/nixos
  ];

  # Use systemd-boot as the bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 16; # Limits the number of boot entries (doesn't influence how many generations are kept during garbage collection though)
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3; # Reduce the timeout to 3 seconds, from 5 seconds (every second counts!)

  # Networking.
  networking.networkmanager.enable = true;
  networking.hostName = "nuc01";

  # SSH.
  coblelab.ssh.enable = true;

  # Timezone.
  coblelab.timezone.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
