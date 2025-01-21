{...}: {
  services.glance = {
    enable = true;
    openFirewall = true;
  };
}
