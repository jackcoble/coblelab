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
        default = "/storage/backups/time-machine";
        description = "The directory to store the Time Machine backups.";
      };

      maxBackupSize = lib.mkOption {
        type = lib.types.str;
        default = "512GiB";
        description = "The maximum size of the Time Machine backups.";
      };
    };

    shares = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      default = {};
      description = "A set of shares to be configured.";
    };
  };

  config = lib.mkMerge [
    # Samba server
    (lib.mkIf (cfg.enable) {
      services.samba = {
        enable = true;
        nmbd.enable = true;
        openFirewall = true;

        settings = {
          "global" = lib.mkMerge [
            # Default settings
            {
              "workgroup" = "WORKGROUP";
              "server string" = "${config.networking.hostName} Samba Server";
              "netbios name" = "${config.networking.hostName}";
              "security" = "user";
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

          # Add the shares
          shares = cfg.shares;
        };
      };
    })

    # Time Machine support
    (lib.mkIf (cfg.enable && cfg.timeMachine.enable) {
      # Create a new user dedicated to Time Machine backups
      # Password manually needs to be set with: `smbpasswd -a time-machine`
      users.groups.time-machine = {};
      users.users.time-machine = {
        isSystemUser = true;
        home = cfg.timeMachine.directory;
        description = "Time Machine Backup";
        group = "time-machine";
      };

      # Create the Time Machine backup directory
      # Permissions are set to 750, so only the `time-machine` user can access it
      systemd.tmpfiles.rules = [
        "D ${cfg.timeMachine.directory} 750 time-machine time-machine"
      ];

      # Create the Time Machine share
      services.samba.settings."Time Machine" = {
        "path" = cfg.timeMachine.directory;
        "comment" = "Time Machine";
        "valid users" = "time-machine";
        "available" = "yes";
        "writable" = "yes";
        "fruit:time machine" = "yes";
        "fruit:time machine max size" = cfg.timeMachine.maxBackupSize;
      };
    })
  ];
}
