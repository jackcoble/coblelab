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

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 16;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;

  # Users
  coblelab.users.jack.enable = true; # Personal user

  # ZFS
  coblelab.zfs.enable = true;
  coblelab.zfs.bootDevice = "/dev/disk/by-id/ata-512GB_SSD_MP33B21003510"; # 512GB Boot NVMe
  coblelab.zfs.hostId = "17bdf883";

  # Impermanence.
  coblelab.impermanence.enable = true;

  # Containers (Podman)
  coblelab.podman.enable = true;
  coblelab.containers.unifi.enable = true;

  # Services
  coblelab.home-assistant.enable = true;

  # Networking.
  networking.networkmanager.enable = true;
  networking.hostName = "nuc01";

  # Tailscale
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.sops.secrets.tailscale-key.path;
  };

  # Git
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
    };
  };

  # SSH.
  coblelab.ssh.enable = true;

  # Backups
  coblelab.backups.enable = true;

  # Disable sudo password for users in the "wheel" group
  security.sudo.wheelNeedsPassword = false;

  # Timezone.
  coblelab.timezone.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
