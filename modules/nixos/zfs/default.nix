/*
This disks module prepares my disks and filesystems (ZFS) ready for installation.
*/
{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.coblelab.disks;
in {
  options.coblelab.disks = {
    enable = lib.mkEnableOption "Disk configuration";
    systemd-boot = lib.mkEnableOption "Use systemd-boot as the bootloader";

    zfs = {
      enable = lib.mkEnableOption "Use ZFS filesystem for Root";

      devices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
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
    (lib.mkIf (cfg.enable && cfg.zfs.enable) {
      # Taken from https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html
      boot.supportedFilesystems = ["zfs" "vfat"];
      boot.zfs.forceImportRoot = false;
      networking.hostId = cfg.zfs.hostId;

      # Extra pools to mount at boot
      # https://nixos.wiki/wiki/ZFS#Importing_pools_at_boot
      boot.zfs.extraPools = ["zstorage"];

      # Disko configuration for Root partition
      disko.devices = {
        disk = {
          # Boot NVMe Drive
          boot-nvme = {
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
              };

              # Persist
              persist = {
                type = "zfs_fs";
                options = {
                  mountpoint = "legacy";
                  "com.sun:auto-snapshot" = "false";
                };
                mountpoint = "${config.coblelab.impermanence.persistDirectory}";
              };
            };
          };
        };
      };
    })
  ];
}
