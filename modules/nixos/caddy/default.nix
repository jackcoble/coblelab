{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.coblelab.caddy;
in {
  options.coblelab.caddy = {
    enable = lib.mkEnableOption "Caddy";
  };

  config = lib.mkIf (cfg.enable) {
    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = ["github.com/caddy-dns/cloudflare@v0.0.0-20240703190432-89f16b99c18e"];
        hash = "sha256-TxgfB4yuRmomBYubeNqoywbngvtWdVr2TfpNWw713Xo=";
      };
    };

    # Allow network access when building
    # https://mdleom.com/blog/2021/12/27/caddy-plugins-nixos/#xcaddy
    nix.settings.sandbox = false;

    # Firewall
    networking.firewall.allowedTCPPorts = [
      80 # Caddy HTTP
      443 # Caddy HTTPS
    ];

    systemd.services.caddy = {
      serviceConfig = {
        # Required to use ports < 1024
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        TimeoutStartSec = "5m";
      };
    };
  };
}
