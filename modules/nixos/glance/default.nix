{...}: {
  services.glance = {
    enable = true;
    openFirewall = true;

    settings = {
      host = "0.0.0.0";
      port = 10000;
    };
  };
}
