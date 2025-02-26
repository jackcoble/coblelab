{
  options,
  config,
  lib,
  ...
}: let
  cfg = config.coblelab.unifi;
in {
  options.coblelab.unifi = {
    enable = lib.mkEnableOption "UniFi Controller";
  };

  config = lib.mkIf cfg.enable {
    services.unifi = {
      enable = true;
      openFirewall = true;
    };
  };
}
