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

      # Systemd service to rollback to the blank root snapshot
      boot.initrd.systemd.enable = true;
      boot.initrd.systemd.services.rollback-blank-root = {
        description = "Rollback BTRFS root subvolume to a pristine state";
        wantedBy = ["initrd.target"];
        after = ["systemd-cryptsetup@crypted.service"];
        before = ["sysroot.mount"];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";

        # Script from https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html#darling-erasure
        # and https://github.com/talyz/nixos-config/blob/b95e5170/machines/evals/configuration.nix#L67-76
        script = ''
          echo "Rolling back BTRFS root subvolume to a pristine state..."

          mkdir -p /btrfs_tmp
          mount -o subvol=@ /dev/mapper/crypted /btrfs_tmp

          if [[ -e /btrfs_tmp/@ ]]; then
            btrfs subvolume list -o /btrfs_tmp/@ |
            cut -f9 -d' ' |
            while read subvol; do
              echo "Deleting $subvol subvolume..." &&
              btrfs subvolume delete "/btrfs_tmp/$subvol"
            done

            echo "Snapshotting @ subvolume..." &&
            btrfs subvolume snapshot -r /btrfs_tmp/@ /btrfs_tmp/@-"$(date +%FT%T)"

            echo "Deleting old @ subvolume..." &&
            btrfs subvolume delete /btrfs_tmp/@
          fi

          echo "Restoring blank @ subvolume..." &&
          btrfs subvolume snapshot /btrfs_tmp/root-blank /btrfs_tmp/@
          sync
          umount /btrfs_tmp
        '';
      };
    })
  ];
}
