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
    initrd-ssh = lib.mkEnableOption "Unlock LUKS remotely via SSH";

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

    # Remote unlock LUKS
    (lib.mkIf (cfg.enable && cfg.initrd-ssh) {
      boot.kernelParams = ["ip=dhcp"];
      boot.initrd.network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222; # Use a different port to avoid conflicts
          shell = "/bin/cryptsetup-askpass";
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBt423fvkSC8SeKVPPAl3MFpwvzwBZ8XEBd4/KrINoP" # M3 Macbook Air
          ];
          hostKeys = ["/etc/ssh/initrd/ssh_host_ed25519_key"];
        };
      };
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
                        mount -t btrfs -o subvol=@ "/dev/mapper/crypted" "$MNTPOINT"
                        btrfs subvolume snapshot -r $MNTPOINT/ $MNTPOINT/root-blank
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
    })
  ];
}
