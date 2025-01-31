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

  # Remote unlock LUKS disk
  coblelab.remoteUnlock.enable = true;
  coblelab.remoteUnlock.authorizedKeys = [sshPublicKeys.user.jack];

  # Impermanence.
  coblelab.impermanence.enable = true;

  # Podman (Containers)
  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

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

  # Pocket ID (OIDC Provider)
  coblelab.pocket-id = {
    enable = true;
    dataDir = "/zstorage/docker/pocket-id";
    environment = {
      PUBLIC_APP_URL = "https://auth.coblelabs.net";
      TRUST_PROXY = "true";
      PUID = "1000";
      PGID = "1000";
      CADDY_PORT = "8081";
    };
  };

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
