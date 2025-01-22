/*
This disks module prepares my boot disk for ZFS.
*/
{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.coblelab.zfs;
in {
  options.coblelab.zfs = {
    enable = lib.mkEnableOption "Enable ZFS";

    bootDevice = lib.mkOption {
      type = lib.types.str;
      default = null;
      description = "Boot NVMe Device";
    };

    hostId = lib.mkOption {
      type = lib.types.str;
      default = null; # `head -c 8 /etc/machine-id`
      description = "Host ID (derived from machine id)";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      boot.supportedFilesystems = ["zfs" "vfat"];
      boot.zfs.forceImportRoot = false;
      boot.zfs.requestEncryptionCredentials = true;
      networking.hostId = cfg.hostId;

      # Extra pools to mount at boot
      # https://nixos.wiki/wiki/ZFS#Importing_pools_at_boot
      boot.zfs.extraPools = ["zstorage"];

      # Disable automatic snapshots (as these are handled by the Sanoid module)
      services.zfs.autoSnapshot.enable = false;

      # Disko configuration for Root partition
      disko.devices = {
        disk = {
          boot-nvme = {
            type = "disk";
            device = cfg.bootDevice;
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

                # ZFS Root (Native Encryption)
                zfs = {
                  size = "100%";
                  content = {
                    type = "zfs";
                    pool = "zroot";
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

            options = {
              ashift = "12";
              autotrim = "on";
            };

            rootFsOptions = {
              acltype = "posixacl";
              canmount = "off";
              dnodesize = "auto";
              normalization = "formD";
              relatime = "on";
              xattr = "sa";
              compression = "lz4";
              mountpoint = "none";
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "file:///tmp/secret.key";
            };

            datasets = {
              # Construct the layout of the Root (/) partition
              # Reserved (space that is gauranteed to be available to the pool)
              reserved = {
                type = "zfs_fs";
                options = {
                  atime = "off";
                  canmount = "off";
                  mountpoint = "none";
                  reservation = "10GiB";
                };
              };

              # Root
              root = {
                type = "zfs_fs";
                options = {
                  atime = "off";
                  canmount = "on";
                  mountpoint = "legacy";
                };

                mountpoint = "/";
                postCreateHook = "zfs snapshot zroot/root@empty";
              };

              # Nix
              nix = {
                type = "zfs_fs";
                options = {
                  atime = "off";
                  canmount = "on";
                  mountpoint = "legacy";
                };

                mountpoint = "/nix";
              };

              # Home
              home = {
                type = "zfs_fs";
                options = {
                  atime = "off";
                  canmount = "on";
                  mountpoint = "legacy";
                };

                mountpoint = "/home";
              };

              # Persist
              persist = {
                type = "zfs_fs";
                options = {
                  atime = "off";
                  canmount = "on";
                  mountpoint = "legacy";
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
