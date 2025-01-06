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
      "protocol" = "SMB3";
      "vfs objects" = "acl_xattr fruit streams_xattr aio_pthread";
      "fruit:aapl" = "yes";
      "fruit:model" = "MacSamba";
      "fruit:posix_rename" = "yes";
      "fruit:metadata" = "stream";
      "fruit:nfs_aces" = "no";
      "recycle:keeptree" = "no";
      "oplocks" = "yes";
      "locking" = "yes";
    };

    # Time Machine share
    settings."Time Machine" = {
      "path" = "/var/lib/time-machine";
      "comment" = "Time Machine";
      "valid users" = "time-machine";
      "writable" = "yes";
      "ea support" = "yes";
      "browseable" = "yes";
      "read only" = "no";
      "inherit acls" = "yes";
      "fruit:time machine" = "yes";
      "fruit:time machine max size" = "512G"; # Cap Time Machine backups to 512GB
    };
  };

  # Enable Avahi for Time Machine discovery
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
}
