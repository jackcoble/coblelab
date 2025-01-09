/*
This module allows for Time Machine backups to be made from my Macbook.

A dedicated `time-machine` user is created for this purpose, with a dedicated
backup directory.
*/
{
  options,
  config,
  lib,
  ...
}: let
  cfg = config.coblelab.timeMachine;
in {
  # Option to enable Time Machine backups
  options.coblelab.timeMachine = {
    enable = lib.mkEnableOption "Enable Time Machine backups";

    directory = lib.mkOption {
      type = lib.types.str;
      default = "/storage/backups/time-machine";
      description = "The directory to store Time Machine backups";
    };

    maxBackupSize = lib.mkOption {
      type = lib.types.str;
      default = "512G";
      description = "The maximum size of Time Machine backups";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create the Time Machine backup directory
    # Permissions are set to 750, so only the `time-machine` user can access it
    systemd.tempfiles.rules = [
      "D ${cfg.directory} 750 time-machine time-machine"
    ];

    # Create a dedicated user for Time Machine backups (accessed via SMB)
    # Password manually needs to be set with: `smbpasswd -a time-machine`
    users.groups.time-machine = {};
    users.users.time-machine = {
      isSystemUser = true;
      home = cfg.directory;
      description = "Time Machine Backup";
      group = "time-machine";
    };

    # Samba service
    services.samba = {
      enable = true;
      nmbd.enable = true;
      openFirewall = true;

      # Global SMB settings
      settings.global = {
        "vfs objects" = "fruit streams_xattr";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
        "fruit:veto_appledouble" = "no";
        "fruit:nfs_aces" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:posix_rename" = "yes";
      };

      # Time Machine share
      settings."Time Machine" = {
        "path" = cfg.directory;
        "comment" = "Time Machine";
        "valid users" = "time-machine";
        "available" = "yes";
        "writable" = "yes";
        "fruit:time machine" = "yes";
        "fruit:time machine max size" = cfg.maxBackupSize;
      };
    };
  };
}
