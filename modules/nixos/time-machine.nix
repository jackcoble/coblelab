/*
This module allows for Time Machine backups to be made from my Macbook.

A dedicated `time-machine` user is created for this purpose, with a dedicated
backup directory.
*/
{
  config,
  ...
}:

{
  # Create a dedicated user for Time Machine backups (accessed via SMB)
  # Password manually needs to be set with: `smbpasswd -a time-machine`
  users.groups.time-machine = {};
  users.users.time-machine = {
    isSystemUser = true;
    home = "/var/lib/time-machine";
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
      "security" = "user";
      "wide links" = "yes";
      "unix extensions" = "no";
      "vfs object" = "acl_xattr catia fruit streams_xattr";
      "fruit:nfs_aces" = "no";
      "fruit:aapl" = "yes";
      "fruit:model" = "MacSamba";
      "fruit:posix_rename" = "yes";
      "fruit:metadata" = "stream";
      "fruit:delete_empty_adfiles" = "yes";
      "fruit:veto_appledouble" = "no";
      "spotlight" = "yes";
    };

    # Time Machine share
    settings."Time Machine" = {
      "path" = "/var/lib/time-machine";
      "comment" = "Time Machine";
      "valid users" = "time-machine";
      "available" = "yes";
      "writable" = "yes";
      "fruit:time machine" = "yes";
      "fruit:time machine max size" = "512G"; # Cap Time Machine backups to 512GB
    };
  };
}
