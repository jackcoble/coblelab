{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.coblelab.adguard;
in {
  options.coblelab.adguard = {
    enable = lib.mkEnableOption "AdGuard Home";
  };

  config = lib.mkIf (cfg.enable) {
    # Enable AdGuard Home DNS
    services.adguardhome = {
      enable = true;
      openFirewall = true;
    };

    # Open the AdGuard Home port (after install)
    # TODO: Make this configurable
    networking.firewall.allowedTCPPorts = [8900 53];
  };
}
