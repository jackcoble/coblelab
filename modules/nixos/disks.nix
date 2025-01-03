/*
This disks module prepares my disks and filesystems (BTRFS) ready for installation.
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

    btrfs = {
      enable = lib.mkEnableOption "Use BTRFS filesystem";
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

    # BTRFS
    (lib.mkIf (cfg.enable && cfg.btrfs.enable) {
      # Partition disks delcaratively with disko
      disko.devices = {
        disk = {
          main = {
            type = "disk";
            device = "/dev/sda";
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

                # LUKS partition
                luks = {
                  size = "100%";
                  label = "luks";
                  content = {
                    type = "luks";
                    name = "crypted";
                    extraOpenArgs = [
                      "--allow-discards"
                      "--perf-no_read_workqueue"
                      "--perf-no_write_workqueue"
                    ];

                    # BTRFS filesystem
                    content = {
                      type = "btrfs";
                      extraArgs = ["-L" "nixos" "-f"];

                      # Create a blank root snapshot for rollback
                      postCreateHook = ''
                        MNTPOINT=$(mktemp -d)
                        mount -o subvol=@ "/dev/mapper/crypted" "$MNTPOINT"
                        btrfs subvolume snapshot -r $MNTPOINT/root $MNTPOINT/root-blank
                        umount "$MNTPOINT"
                      '';

                      subvolumes = {
                        "@" = {
                          mountpoint = "/";
                          mountOptions = ["compress=zstd" "noatime"];
                        };

                        "@home" = {
                          mountpoint = "/home";
                          mountOptions = ["compress=zstd" "noatime"];
                        };

                        "@nix" = {
                          mountpoint = "/nix";
                          mountOptions = ["compress=zstd" "noatime"];
                        };

                        "@persist" = {
                          mountpoint = "/persist";
                          mountOptions = ["compress=zstd" "noatime"];
                        };

                        "@log" = {
                          mountpoint = "/var/log";
                          mountOptions = ["compress=zstd" "noatime"];
                        };

                        "@swap" = {
                          mountpoint = "/swap";
                          swap.swapfile.size = "32G";
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };

      fileSystems."/persist".neededForBoot = true;
      fileSystems."/var/log".neededForBoot = true;

      # Load the blank root snapshot each boot
      boot.initrd.postDeviceCommands = pkgs.lib.mkAfter ''
        mkdir -p /mnt

        # Mount the btrfs root to /mnt
        mount -o subvol="@" /dev/mapper/crypted /mnt

        # Delete root subvolume
        btrfs subvolume delete /mnt/root

        # Restore new root from root-blank
        btrfs subvolume snapshot /mnt/root-blank /mnt/root

        # Unmount /mnt and continue
        umount /mnt
      '';
    })
  ];
}
