{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.coblelab.home-assistant;
in {
  options.coblelab.home-assistant = {
    enable = lib.mkEnableOption "Home Assistant";
  };

  config = lib.mkIf (cfg.enable) {
    services.home-assistant = {
      enable = true;
      openFirewall = true;
    };
  };
}
