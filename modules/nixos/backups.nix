/*
This backups module uses Restic to backup
*/
{
  pkgs,
  config,
  ...
}: {
  services.restic.backups = {
    hetzner-storage-box = {
      # Repository information
      repository = "sftp://u441231@u441231.your-storagebox.de:23/./${config.networking.hostName}";
      initialize = true;
      passwordFile = config.sops.secrets.restic-password.path; # Encryption password
      extraOptions = [
        "sftp.command='ssh u441231@u441231.your-storagebox.de -p 23 -i /etc/ssh/ssh_host_ed25519_key -s sftp'"
      ];

      # What do we want to back up?
      paths = [
        "/persist"
      ];

      # Backup schedule
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };

      # Prune options
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 12"
        "--keep-yearly 4"
      ];
    };
  };
}
