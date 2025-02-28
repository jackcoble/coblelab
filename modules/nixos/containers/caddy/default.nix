{
  options,
  config,
  lib,
  ...
}: let
  cfg = config.coblelab.containers.caddy;
in {
  options.coblelab.containers.caddy = {
    enable = lib.mkEnableOption "Caddy";

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/caddy";
      description = "The directory where Caddy will store its data";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create user and group for Caddy
    users.groups.caddy = {};
    users.users.caddy = {
      isSystemUser = true;
      group = "caddy";
    };

    # Create the data directory
    systemd.tmpfiles.rules = [
      "f ${cfg.dataDir}/Caddyfile 0755 caddy caddy -"
      "d ${cfg.dataDir}/data 0755 caddy caddy -"
      "d ${cfg.dataDir}/config 0755 caddy caddy -"
    ];

    # Create the Caddy container
    virtualisation.oci-containers.containers."caddy" = {
      image = "ghcr.io/caddybuilds/caddy-cloudflare:latest";
      volumes = [
        "${cfg.dataDir}/Caddyfile:/etc/caddy/Caddyfile"
        "${cfg.dataDir}/data:/data"
        "${cfg.dataDir}/config:/config"
      ];
      ports = [
        "80:80"
        "443:443"
      ];
    };

    # Open 80 + 443 TCP ports
    networking.firewall.allowedTCPPorts = [80 443];

    # Set kernel parameters to allow 80 to be the lowest unprivileged port
    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

    # If Persistance mode is enabled, ensure the data directory is persisted
    environment.persistence."${config.coblelab.impermanence.persistDirectory}" = {
      directories = [cfg.dataDir];
    };

    # Restic
    services.restic.backups.hetzner-storage-box.paths = ["${dataDir}"];
  };
}
