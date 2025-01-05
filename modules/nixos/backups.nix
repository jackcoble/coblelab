/*
This backups module uses Borg Backup to back up my hosts to an off-site location
*/
{config, ...}: {
  services.borgbackup.jobs."hetzner-storagebox" = {
    /*
    repo is stored on a Hetzner Storage Box:
    https://community.hetzner.com/tutorials/install-and-configure-borgbackup
    */
    repo = "ssh://u441231@u441231.your-storagebox.de:23/./backups/${config.networking.hostName}";

    # i want to use the ssh host key of the machine for backup access
    # really i should generate a dedicated key
    environment.BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key";

    extraArgs = "--lock-wait=1200"; # wait up to 20 min = 1200 s for a repository lock

    doInit = true; # initialise repo if it doesn't exist
    encryption = {
      mode = "repokey"; # the key is stored in the repo
      passCommand = "cat ${config.sops.secrets."borg-backup/password".path}"; # re-using the encryption key for all hosts will probably bite me at some point
    };

    # runs a backup on boot if it would have been run whilst the system was powered off
    persistentTimer = true;

    # rules for the amount of backups I want to keep
    # https://borgbackup.readthedocs.io/en/stable/usage/prune.html
    prune.keep = {
      within = "1d"; # archives from the last 24h are always kept
      daily = 7;
      weekly = 4;
      monthly = 6;
      yearly = 3;
    };

    # by default lz4 is used by borg
    # though I use zstd to save on space (also in use by my btrfs disk)
    # use `auto` for any data that cannot be compressed
    compression = "auto,zstd";

    # what do i want to backup?
    # my system is ephemeral, so at the moment only `/persist` needs backing up
    paths = [
      "/persist"
    ];
  };
}
