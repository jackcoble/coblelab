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

      # Only use compatible Linux kernel, since ZFS can be behind
      boot.kernelPackages = pkgs.linuxPackages; # Defaults to latest LTS
      boot.kernelParams = ["nohibernate"];

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

    # If impermanence is enabled, we should roll back to the empty root snapshot
    # on each boot
    # Note: https://github.com/NixOS/nixpkgs/issues/341542
    (lib.mkIf (config.coblelab.impermanence.enable) {
      boot.initrd.postResumeCommands = lib.mkAfter ''
        zfs rollback -r zroot/root@empty
      '';

      # Filesystems need to be available for boot
      # Persistence directory is needed for Impermanence
      fileSystems."${config.coblelab.impermanence.persistDirectory}".neededForBoot = true;
    })
  ];
}
