{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.coblelab.podman;
in {
  options.coblelab.podman = {
    enable = lib.mkEnableOption "Podman";
  };

  config = lib.mkIf (cfg.enable) {
    virtualisation.containers.enable = true;
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
