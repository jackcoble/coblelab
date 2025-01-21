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

  # Tailscale
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.sops.secrets.tailscale-key.path;
  };

  # Cloudflare Tunnel
  coblelab.cloudflared.enable = true;
  coblelab.cloudflared.tunnelId = "eabac83f-e584-4e75-bbc7-cf1ff7b77c0e";

  # Testing - Uptime Kuma
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
      PORT = "4000";
    };
  };

  # Fixes DNS not working after initrd
  # https://github.com/NixOS/nixpkgs/issues/63941#issuecomment-2081126437
  boot.initrd.network.udhcpc.enable = true;
  boot.initrd.network.flushBeforeStage2 = true;

  # SSH.
  coblelab.ssh.enable = true;

  # Backups
  coblelab.backups.enable = true;

  # Samba & Time Machine
  coblelab.samba.enable = true;
  coblelab.samba.timeMachine.enable = true;

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
