{...}: {
  virtualisation.oci-containers.containers."pocket-id" = {
    image = "ghcr.io/stonith404/pocket-id";

    volumes = [
      "/zstorage/docker/pocket-id:/app/backend/data"
    ];

    ports = [
      "127.0.0.1:11000:80"
    ];

    environment = {
      # See the README for more information: https://github.com/stonith404/pocket-id?tab=readme-ov-file#environment-variables
      PUBLIC_APP_URL = "https://auth.coblelabs.net";
      TRUST_PROXY = false;
      MAXMIND_LICENSE_KEY = "";
      PUID = "1000";
      PGID = "1000";
    };
  };
}
