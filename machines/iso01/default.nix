{
  # Apply personal SSH key to "nixos" user.
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBt423fvkSC8SeKVPPAl3MFpwvzwBZ8XEBd4/KrINoP"
    ];
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
