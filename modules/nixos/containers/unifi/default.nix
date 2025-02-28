/*
* UniFi Controller has its own user/group and data directory.
*/
{
  config,
  pkgs,
  lib,
  ...
}: let
  containerName = "unifi-controller";
  dataDir = "/var/lib/unifi";
  image = "jacobalberty/unifi:latest";
in {
  options = {
    coblelab.containers.unifi.enable = lib.mkEnableOption "UniFi Controller";
  };

  config = lib.mkMerge [
    (lib.mkIf config.coblelab.containers.unifi.enable {
      environment.systemPackages = [pkgs.podman];

      systemd.tmpfiles.rules = [
        "d ${dataDir} 0755 unifi unifi -"
      ];

      users.groups.unifi = {};
      users.users.unifi = {
        isSystemUser = true;
        group = "unifi";
      };

      virtualisation.oci-containers.containers.${containerName} = {
        image = image;
        autoStart = true;
        ports = ["8443:8443" "8080:8080" "3478:3478/udp" "10001:10001/udp"];
        volumes = ["${dataDir}:/unifi"];
        environment = {
          TZ = "UTC";
        };
        extraOptions = ["--network=host"];
      };

      networking.firewall.allowedTCPPorts = [8443 8080];
      networking.firewall.allowedUDPPorts = [3478 10001];

      # Caddy
      services.caddy.virtualHosts."unifi.coble.casa".extraConfig = ''
        tls {
          dns cloudflare {env.cloudflare-api-key}
        }
        reverse_proxy localhost:8443 {
          transport http {
            tls_insecure_skip_verify
          }
        }
      '';
    })

    # If Persistance mode is enabled, ensure the data directory is persisted
    (lib.mkIf config.coblelab.impermanence.enable {
      environment.persistence."${config.coblelab.impermanence.persistDirectory}" = {
        directories = [dataDir];
      };
    })

    # If the backups module is enabled, ensure the "auto backups" from the controller are backed up
    (lib.mkIf config.coblelab.backups.enable {
      services.restic.backups.hetzner-storage-box.paths = ["${dataDir}/data/backup/autobackup"];
    })
  ];
}
