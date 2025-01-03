{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  # Networking.
  networking.networkmanager.enable = true;
  networking.hostName = "nuc01";

  # Enable OpenSSH.
  services.openssh.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
