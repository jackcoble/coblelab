/*
This SOPS module takes care of loading secrets, decrypting them using the Host SSH Key
*/
{...}: {
  sops.age.sshKeyPaths = [
    # on first activation the symlink to /etc isn't there yet
    "/persist/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_ed25519_key"
  ];
  sops.defaultSopsFile = ../../secrets/secrets.yaml;

  # Declare secrets
  sops.secrets = {
    jack-password = {
      neededForUsers = true;
    };

    "restic/password" = {};
    "restic/repository-url" = {};
  };
}
