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
}: let
  cfg = config.coblelab.remoteUnlock;
in {
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

  config = lib.mkIf cfg.enable {
    /*
    TODO: Re-enable when I can figure out systemd initrd
    */
  };
}
