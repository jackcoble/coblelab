{
  options,
  config,
  lib,
}: let
  cfg = config.coblelab.ssh;
in {
  options.coblelab.ssh = {
    enable = lib.mkEnableOption "SSH server";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      # Enable OpenSSH Server
      enable = true;

      # Disable root login and only allow public key authentication
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };

      # Only generate Ed25519 host key
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };
}
