{
  config,
  pkgs,
  sshPublicKeys,
  ...
}: {
  imports = [
    ../../modules/nixos
  ];

  # Enable Nix Flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # This host is a QEMU Guest
  services.qemuGuest.enable = true;

  # Users
  coblelab.users.jack.enable = true; # Personal user

  # ZFS
  coblelab.zfs.enable = true;
  coblelab.zfs.bootDevice = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0"; # Virtual disk
  coblelab.zfs.hostId = "17bdf883";

  # Impermanence.
  coblelab.impermanence.enable = true;

  # Networking.
  networking.networkmanager.enable = true;
  networking.hostName = "virt01";

  # Fixes DNS not working after initrd
  # https://github.com/NixOS/nixpkgs/issues/63941#issuecomment-2081126437
  boot.initrd.network.udhcpc.enable = true;
  boot.initrd.network.flushBeforeStage2 = true;

  # SSH.
  coblelab.ssh.enable = true;

  # Disable sudo password for users in the "wheel" group
  security.sudo.wheelNeedsPassword = false;

  # Timezone.
  coblelab.timezone.enable = true;

  # System Packages
  environment.systemPackages = with pkgs; [
    sops
    age
    ssh-to-age
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
