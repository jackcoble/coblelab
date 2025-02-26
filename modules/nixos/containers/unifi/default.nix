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

  config = lib.mkIf config.coblelab.containers.unifi-controller.enable {
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
  };
}
