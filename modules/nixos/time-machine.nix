/*
This module allows for Time Machine backups to be made from my Macbook.

A dedicated `time-machine` user is created for this purpose, with a dedicated
backup directory.
*/
{
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
    
    settings = {
      "Time Machine" = {
        path = "/var/lib/time-machine";
        "valid users" = "time-machine";
        public = "no";
        writeable = "yes";
        "force user" = "time-machine";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        
        # We're an iPhone 3GS. Don't question it.
        "fruit:model" = "N88AP";
        "vfs objects" = "catia fruit streams_xattr";
      };
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
