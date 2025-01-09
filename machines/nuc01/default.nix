{
  config,
  pkgs,
  sshPublicKeys,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  # Enable Nix Flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Users
  coblelab.users.jack.enable = true; # Personal user

  # Disks.
  coblelab.disks.enable = true;
  coblelab.disks.systemd-boot = true;

  # ZFS
  coblelab.disks.zfs.enable = true;
  coblelab.disks.zfs.devices = [
    "/dev/disk/by-id/ata-512GB_SSD_MP33B21003510" # 512GB Boot NVMe
    "/dev/disk/by-id/usb-Micron_CT1000X9SSD9_2419E8D193A0-0:0" # 1TB External Crucial X9 SSD
    "/dev/disk/by-id/usb-SSK_SSK_Storage_DD564198838B8-0:0" # 1TB Crucial P2 CT1000P2SSD8 NVMe (External USB-C Enclosure)
  ];
  coblelab.disks.zfs.hostId = "17bdf883";
  coblelab.disks.zfs.reservation = "10GiB";

  # Remote unlock LUKS disk
  coblelab.remoteUnlock.enable = true;
  coblelab.remoteUnlock.authorizedKeys = [sshPublicKeys.user.jack];

  # Impermanence.
  coblelab.impermanence.enable = true;

  # Networking.
  networking.networkmanager.enable = true;
  networking.hostName = "nuc01";

  # Fixes DNS not working after initrd
  # https://github.com/NixOS/nixpkgs/issues/63941#issuecomment-2081126437
  boot.initrd.network.udhcpc.enable = true;
  boot.initrd.network.flushBeforeStage2 = true;

  # SSH.
  coblelab.ssh.enable = true;

  # Backups
  coblelab.backups.enable = true;
  coblelab.timeMachine.enable = true;

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
