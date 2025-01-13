/*
This module allows unlocking encrypted partitions remotely via SSH.
This is achieved by enabling the network and SSH server in initrd.

The network driver kernel module must be avaialble to
boot.initrd.availableKernelModules
*/
{
  pkgs,
  config,
  lib,
  ...
}: {
  options.coblelab.remoteUnlock = {
    enable = lib.mkEnableOption "Unlock LUKS remotely via SSH";

    port = lib.mkOption {
      type = lib.types.int;
      default = 2222;
      description = "The port to listen on for SSH";
    };

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of authorized SSH keys";
    };
  };

  config = lib.mkIf config.coblelab.remoteUnlock.enable {
    boot.kernelParams = ["ip=dhcp"];
    boot.initrd.network = {
      enable = true;

      ssh = {
        enable = true;
        port = config.coblelab.remoteUnlock.port;
        shell = "/bin/cryptsetup-askpass";
        authorizedKeys = config.coblelab.remoteUnlock.authorizedKeys;
        hostKeys = ["/etc/ssh/ssh_boot_ed25519_key"];
      };

      postCommands = ''
        sleep 2

        # Import all ZPools
        zpool import -a

        # Unlock pools
        zfs load-key -a
      '';
    };

    # Persist the SSH Boot Keys
    environment.persistence."${config.coblelab.impermanence.persistDirectory}".files = [
      "/etc/ssh/ssh_boot_ed25519_key"
      "/etc/ssh/ssh_boot_ed25519_key.pub"
    ];
  };
}
