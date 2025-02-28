{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.coblelab.containers.caddy;
in {
  options.coblelab.containers.caddy = {
    enable = lib.mkEnableOption "Caddy";
  };

  config = lib.mkIf cfg.enable {
    # Allow network access when building
    nix.settings.sandbox = false;

    # Expose ports through Firewall
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    # Caddy service
    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = ["github.com/caddy-dns/cloudflare@v0.0.0-20240703190432-89f16b99c18e"];
        hash = "sha256-kbTKCPjjIGRZZ550lBg0c5Ye4AK4o5yCRynBIvCLYkQ=";
      };
    };

    systemd.services.caddy = {
      serviceConfig = {
        # Required to use ports < 1024
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        EnvironmentFile = config.sops.secrets.cloudflare-api-key.path;
        TimeoutStartSec = "5m";
      };
    };
  };
}
