/*
This SOPS module takes care of loading secrets, decrypting them using the Host SSH Key
*/
{...}: {
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  # Declare secrets
  sops.secrets = {
    jack-password = {
      sopsFile = ../../secrets/secrets.yaml;
      neededForUsers = true;
    };
  };
}
