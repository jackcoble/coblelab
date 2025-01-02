/*
Settings for OpenSSH Server
*/
{
  services.openssh = {
    enable = true;

    # Allow OpenSSH in the system firewall
    openFirewall = true;

    settings = {
      # Disable root login and only allow public key authentication
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
