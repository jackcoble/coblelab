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
    securityType = "user";
    
    # Global SMB settings
    settings.global = {
      workgroup = "WORKGROUP";
      "server string" = "${config.networking.hostName}";
      "netbios name" = "${config.networking.hostName}";
      "hosts allow" = "10.0.7. 10.0.2. 10.2.0. 100.64.0.0/10 127.0.0.1 localhost";
      "hosts deny" = "0.0.0.0/0";
      "guest account" = "nobody";
      "map to guest" = "bad user";
      "min protocol" = "SMB2";
      "ea support" = "yes";
      "browseable" = "yes";
      "smb encrypt" = "auto";
      "load printers" = "no";
      "printcap name" = "/dev/null";
      "bind interfaces only" = "yes";
      "interfaces" = "lo br0 tailscale0";
      "vfs objects" = "catia fruit streams_xattr";
      "fruit:aapl" = "yes";
      "fruit:posix_rename" = "yes";
      "fruit:nfs_aces" = "no";
      "fruit:zero_file_id" = "yes";
      "fruit:metadata" = "stream";
      "fruit:encoding" = "native";
      "spotlight backend" = "tracker";
      "fruit:model" = "MacPro7,1@ECOLOR=226,226,224";
      "fruit:wipe_intentionally_left_blank_rfork" = "yes";
      "fruit:delete_empty_adfiles" = "yes";
      "fruit:veto_appledouble" = "no";
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
