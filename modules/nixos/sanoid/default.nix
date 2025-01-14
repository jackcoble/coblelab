{...}: {
  services.sanoid = {
    enable = true;

    templates.backup = {
      frequently = 90;
      hourly = 24;
      daily = 14;
      monthly = 12;
      yearly = 3;

      autoprune = true;
      autosnap = true;
    };

    # ZFS Datasets to snapshot
    datasets."zstorage/backups" = {
      useTemplate = ["backup"];
    };

    datasets."zstorage/photos" = {
      useTemplate = ["backup"];
    };
  };
}
