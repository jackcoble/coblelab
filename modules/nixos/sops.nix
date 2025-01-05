/*
This SOPS module takes care of loading secrets, decrypting them using the Host SSH Key
*/
{...}: {
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.defaultSopsFile = ../../secrets/secrets.yaml;

  # Declare secrets
  sops.secrets = {
    jack-password = {
      neededForUsers = true;
    };
  };
}
