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
                        mount "/dev/mapper/crypted" "$MNTPOINT" -o subvol=@root
                        trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
                        btrfs subvolume snapshot -r $MNTPOINT/ $MNTPOINT/root-blank
                      '';

                      subvolumes = {
                        "@root" = {
                          mountpoint = "/";
                          mountOptions = ["subvol=@root" "compress=zstd" "noatime"];
                        };

                        "@home" = {
                          mountpoint = "/home";
                          mountOptions = ["subvol=@home" "compress=zstd" "noatime"];
                        };

                        "@nix" = {
                          mountpoint = "/nix";
                          mountOptions = ["subvol=@nix" "compress=zstd" "noatime"];
                        };

                        "@persist" = {
                          mountpoint = "/persist";
                          mountOptions = ["subvol=@persist" "compress=zstd" "noatime"];
                        };

                        "@log" = {
                          mountpoint = "/var/log";
                          mountOptions = ["subvol=@log" "compress=zstd" "noatime"];
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
    })
  ];
}