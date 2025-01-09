/*
This disks module prepares my disks and filesystems (ZFS) ready for installation.
*/
{
  options,
  config,
  lib,
  ...
}: let
  cfg = config.coblelab.disks;
in {
  options.coblelab.disks = {
    enable = lib.mkEnableOption "Disk configuration";
    systemd-boot = lib.mkEnableOption "Use systemd-boot as the bootloader";

    zfs = {
      enable = lib.mkEnableOption "Use ZFS filesystem";

      devices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "/dev/disk/by-id/ata-512GB_SSD_MP33B21003510" # 512GB Boot NVMe
          "/dev/disk/by-id/usb-Micron_CT1000X9SSD9_2419E8D193A0-0:0" # 1TB External Crucial X9 SSD
          "/dev/disk/by-id/usb-SSK_SSK_Storage_DD564198838B8-0:0" # 1TB Crucial P2 CT1000P2SSD8 NVMe (External USB-C Enclosure)
        ];
        description = "List of devices to use for ZFS";
      };

      hostId = lib.mkOption {
        type = lib.types.str;
        default = "17bdf883"; # `head -c 8 /etc/machine-id`
        description = "Host ID (derived from machine id)";
      };

      reservation = lib.mkOption {
        type = lib.types.str;
        default = "20GiB";
        description = "ZFS reservation for pool";
      };
    };
  };

  config = lib.mkMerge [
    # systemd-boot
    (lib.mkIf (cfg.enable && cfg.systemd-boot) {
      boot.loader.systemd-boot.enable = true;
      boot.loader.systemd-boot.configurationLimit = 16;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.timeout = 3;
    })

    # ZFS
    (lib.mkIf (cfg.enable && cfg.zfs.enable) {
      boot.supportedFilesystems = ["zfs" "vfat"];
      networking.hostId = cfg.zfs.hostId;
      services.zfs.autoScrub.enable = true;

      # Disko configuration for Root partition
      disko.devices = {
        disk = {
          # Boot NVMe Drive
          "ata-512GB_SSD_MP33B21003510" = {
            type = "disk";
            device = builtins.elemAt cfg.zfs.devices 0;
            content = {
              type = "gpt";
              partitions = {
                # Boot partition
                ESP = {
                  label = "boot";
                  name = "ESP";
                  size = "512M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [
                      "umask=0077"
                    ];
                  };
                };

                # LUKS Partition (contains ZFS Root)
                luks = {
                  size = "100%";

                  content = {
                    type = "luks";
                    name = "cryptroot";
                    passwordFile = "/tmp/secret.key"; # Supplied via nixos-install
                    settings.allowDiscards = true;

                    # ZFS Root
                    content = {
                      type = "zfs";
                      pool = "zroot";
                    };
                  };
                };
              };
            };
          };
        };

        # ZFS Pools
        zpool = {
          # Root Pool
          zroot = {
            type = "zpool";
            mode = ""; # TODO: Only have 1 drive so this is blank for now
            rootFsOptions = {
              compression = "zstd";
              mountpoint = "none";
              relatime = "on";
              "com.sun:auto-snapshot" = "false";
            };

            options = {
              ashift = "12";
              autotrim = "on";
            };

            datasets = {
              # Construct the layout of the Root (/) partition
              # Reserved (space that is gauranteed to be available to the pool)
              reserved = {
                type = "zfs_fs";
                options = {
                  canmount = "off";
                  mountpoint = "none";
                  reservation = "${cfg.zfs.reservation}";
                };
              };

              # Root
              root = {
                type = "zfs_fs";
                options = {
                  mountpoint = "legacy";
                  "com.sun:auto-snapshot" = "false";
                };
                mountpoint = "/";
                postCreateHook = "zfs snapshot zroot/root@empty";
              };

              # Nix
              nix = {
                type = "zfs_fs";
                mountpoint = "/nix";
                options = {
                  atime = "off";
                  canmount = "on";
                  mountpoint = "legacy";
                  "com.sun:auto-snapshot" = "false";
                };
                postCreateHook = "zfs snapshot zroot/nix@empty";
              };

              # Home
              home = {
                type = "zfs_fs";
                mountpoint = "/home";
                options = {
                  atime = "off";
                  canmount = "on";
                  mountpoint = "legacy";
                  "com.sun:auto-snapshot" = "false";
                };
                postCreateHook = "zfs snapshot zroot/home@empty";
              };

              # Persist
              persist = {
                type = "zfs_fs";
                options = {
                  mountpoint = "legacy";
                  "com.sun:auto-snapshot" = "false";
                };
                mountpoint = "${config.coblelab.impermanence.persistDirectory}";
                postCreateHook = "zfs snapshot zroot/persist@empty";
              };
            };
          };
        };
      };

      # Filesystems need to be available for boot
      # Persistence directory is needed for Impermanence
      fileSystems."${config.coblelab.impermanence.persistDirectory}".neededForBoot = true;
    })

    # If impermanence is enabled, we should roll back to the empty root snapshot
    # on each boot
    (lib.mkIf (config.coblelab.impermanence.enable) {
      boot.initrd.postDeviceCommands = lib.mkAfter ''
        zfs rollback -r zroot/root@empty
      '';
    })
  ];
}
