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
      path = "/var/lib/time-machine";
      comment = "Time Machine";
      browseable = "yes";
      public = "no";
      writeable = "yes";
      "force user" = "time-machine";
      "force group" = "time-machine";
      "fruit:aapl" = "yes";
      "fruit:time machine" = "yes";
      "fruit:time machine max size" = "512G"; # Cap Time Machine backups to 512GB
      "vfs objects" = "catia fruit streams_xattr";
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
