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

      # What do we want to back up?
      paths = [
        "/persist"
      ];

      # Backup schedule
      timerConfig = {
        OnCalendar = "00:00";
        RandomizedDelaySec = "1h";
      };
    };
  };
}
