/*
This machine configuration is for creating a custom NixOS Installer ISO
with my personal SSH key added to it.
*/
{sshPublicKeys, ...}: {
  # Apply personal SSH key to "nixos" user.
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [sshPublicKeys.user.jack];
  };

  # Disable password for "sudo"
  security.sudo.wheelNeedsPassword = false;

  # Enable OpenSSH.
  services.openssh.enable = true;

  # Experimental features.
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Networking hostname
  networking.hostName = "iso01";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
