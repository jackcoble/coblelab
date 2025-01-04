{
  pkgs,
  sshPublicKeys,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  # Enable Nix Flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Disks.
  coblelab.disks.enable = true;
  coblelab.disks.systemd-boot = true;
  coblelab.disks.btrfs.enable = true;

  # Remote unlock LUKS disk
  coblelab.remoteUnlock.enable = true;
  coblelab.remoteUnlock.authorizedKeys = [sshPublicKeys.user.jack];

  # Impermanence.
  coblelab.impermanence.enable = true;

  # Networking.
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.hostName = "nuc01";

  # SSH.
  coblelab.ssh.enable = true;

  # Users.
  users = {
    # Keeps users declarative
    mutableUsers = false;

    users = {
      jack = {
        isNormalUser = true;
        extraGroups = ["wheel"];

        # password can be hashed with: nix run nixpkgs#mkpasswd -- -m SHA-512 -s
        hashedPassword = "$6$t46MsRsGAx1W0DIA$51tiEPtZmfF3Faowd53efIrFw0iiHfqiT4zNxGLCDTCiWy9iUhznJ8xZhsApqGN92IwhMsera2GvlYpgcDlwl/";
        openssh.authorizedKeys.keys = [sshPublicKeys.user.jack];
      };
    };
  };

  # Timezone.
  coblelab.timezone.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
