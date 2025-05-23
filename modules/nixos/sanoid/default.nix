{...}: {
  services.sanoid = {
    enable = true;

    # Interval is every 15 minutes
    interval = "*:0/15";

    templates.backup = {
      frequently = 24;
      hourly = 24;
      daily = 14;
      monthly = 12;
      yearly = 3;

      autoprune = true;
      autosnap = true;
    };

    # ZFS Datasets to snapshot
    datasets."zflash/backups" = {
      useTemplate = ["backup"];
    };

    datasets."zflash/photos" = {
      useTemplate = ["backup"];
    };
  };
}
