{
  options,
  config,
  lib,
  ...
}: let
  cfg = config.coblelab.pocket-id;
in {
  # Configuration options
  options.coblelab.pocket-id = {
    enable = lib.mkEnableOption "Enable Pocket ID";

    port = lib.mkOption {
      type = lib.types.int;
      default = 11000;
      description = "The port on which Pocket ID will listen";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = null;
      description = "The directory where Pocket ID will store its data";
    };

    # See the README for more information: https://github.com/stonith404/pocket-id?tab=readme-ov-file#environment-variables
    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Environment variables to pass to the Pocket ID container";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers."pocket-id" = {
      image = "ghcr.io/stonith404/pocket-id";
      environment = cfg.environment;
      volumes = [
        "${cfg.dataDir}:/app/backend/data"
      ];
      ports = [
        "127.0.0.1:${toString cfg.port}:8081"
      ];
    };
  };
}
