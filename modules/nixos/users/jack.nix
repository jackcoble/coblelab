{
  options,
  config,
  lib,
  sshPublicKeys,
  ...
}: let
  cfg = config.coblelab.users;
in {
  # Option to enable this user
  options.coblelab.users.jack = {
    enable = lib.mkEnableOption "Enable the 'jack' user";
  };

  # Configuration for this user
  config = lib.mkIf cfg.jack.enable {
    users.users.jack = {
      uid = 1000; # Hardcoded UID
      isNormalUser = true;
      extraGroups = ["wheel"];
      hashedPasswordFile = config.sops.secrets.jack-password.path;
      openssh.authorizedKeys.keys = [sshPublicKeys.user.jack];
      group = "jack";
    };

    users.groups.jack.gid = 1000; # Hardcoded GID
  };
}
