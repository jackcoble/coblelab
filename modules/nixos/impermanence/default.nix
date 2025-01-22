{
  options,
  config,
  lib,
  ...
}: let
  cfg = config.coblelab.impermanence;
in {
  options.coblelab.impermanence = {
    enable = lib.mkEnableOption "Impermanence";

    persistDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "The directory to persist between reboots";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.persistence."${cfg.persistDirectory}" = {
      # Running on servers for the time being, but hiding mounts from the sidebars of file managers can't hurt anyone!
      hideMounts = true;

      # Directories we want to keep
      directories = [
        "/var/log" # system logs
        "/var/lib/nixos"
        "/var/lib/systemd" # systemd state
        "/var/lib/btrfs" # btrfs state
      ];

      # Files we want to keep
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
    };

    # Disable sudo from lecturing us after each reboot
    security.sudo.extraConfig = ''
      Defaults lecture = never
    '';

    # Roll back to the empty root snapshot on each boot
    # Note: https://github.com/NixOS/nixpkgs/issues/341542
    boot.initrd.postResumeCommands = lib.mkAfter ''
      zfs rollback -r zroot/root@empty
    '';

    # Filesystems need to be available for boot
    fileSystems."${config.coblelab.impermanence.persistDirectory}".neededForBoot = true;
  };
}
