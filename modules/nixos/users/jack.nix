{
  lib,
  config,
  ...
}: {
  # Option to enable this user
  options.coblelab.users.jack = {
    enable = lib.mkEnableOption "Enable the 'jack' user";
  };

  # Configuration for this user
  config = lib.mkIf config.coblelab.users.jack.enable {
    users.users.jack = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      hashedPasswordFile = config.sops.secrets.jack-password.path;
      openssh.authorizedKeys.keys = [config.sshPublicKeys.user.jack];
    };
  };
}
