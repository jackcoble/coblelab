{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.coblelab.samba;
in {
  options.coblelab.samba = {
    enable = lib.mkEnableOption "Samba server";

    # Time Machine support for macOS
    timeMachine = {
      enable = lib.mkEnableOption "Time Machine support";

      directory = lib.mkOption {
        type = lib.types.str;
        default = "/zflash/backups/time-machine";
        description = "The directory to store the Time Machine backups.";
      };

      maxBackupSize = lib.mkOption {
        type = lib.types.str;
        default = "512GiB";
        description = "The maximum size of the Time Machine backups.";
      };
    };
  };

  config = lib.mkMerge [
    # Samba server
    (lib.mkIf (cfg.enable) {
      # Create a group for Samba users
      users.groups.samba-users = {};

      services.samba = {
        enable = true;
        nmbd.enable = true;
        openFirewall = true;

        settings = {
          "global" = lib.mkMerge [
            # Default settings
            {
              "workgroup" = "WORKGROUP";
              "server string" = "${config.networking.hostName}";
              "netbios name" = "${config.networking.hostName}";
              "security" = "user";
              "valid users" = "@samba-users";
            }

            # Time Machine settings
            (lib.mkIf (cfg.timeMachine.enable) {
              "vfs objects" = "fruit streams_xattr";
              "fruit:metadata" = "stream";
              "fruit:model" = "MacSamba";
              "fruit:veto_appledouble" = "no";
              "fruit:nfs_aces" = "no";
              "fruit:wipe_intentionally_left_blank_rfork" = "yes";
              "fruit:delete_empty_adfiles" = "yes";
              "fruit:posix_rename" = "yes";
            })
          ];

          # Shares (TODO: Make this configurable)
          "Photos" = {
            "path" = "/zflash/photos";
            "comment" = "Photos";
            "available" = "yes";
            "writable" = "yes";
          };
        };
      };
    })

    # Time Machine support
    (lib.mkIf (cfg.enable && cfg.timeMachine.enable) {
      # Create the Time Machine backup directory
      # Permissions are set to 750, so only users in the "samba-users" group can access it
      # After don't forget: `smbpasswd -a jack`
      systemd.tmpfiles.rules = [
        "d ${cfg.timeMachine.directory} 750 - samba-users"
      ];

      # Create the Time Machine share
      services.samba.settings."Time Machine" = {
        "path" = cfg.timeMachine.directory;
        "comment" = "Time Machine";
        "available" = "yes";
        "writable" = "yes";
        "fruit:time machine" = "yes";
        "fruit:time machine max size" = cfg.timeMachine.maxBackupSize;
      };
    })
  ];
}
