{
  config,
  lib,
  options,
  ...
}: let
  cfg = config.coblelab.cloudflared;
in {
  # Cloudflare Tunnel configuration options
  options.coblelab.cloudflared = {
    enable = lib.mkEnableOption "Enable Cloudflare Tunnels";

    tunnelId = lib.mkOption {
      type = lib.types.str;
      default = null;
      description = "Cloudflare Tunnel ID";
    };
  };

  config = lib.mkIf cfg.enable {
    services.cloudflared = {
      enable = true;
      tunnels = {
        ${cfg.tunnelId} = {
          credentialsFile = "${config.sops.secrets.cloudflare-tunnel.path}";
          default = "http_status:404";
        };
      };
    };
  };
}
