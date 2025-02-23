{
  config,
  pkgs,
  sshPublicKeys,
  modulesPath,
  ...
}: {
  imports = [
    ../../modules/nixos
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  # Proxmox
  nix.settings.sandbox = false;
  proxmoxLXC = {
    manageNetwork = false;
    privileged = true;
  };

  # Enable Nix Flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Users
  coblelab.users.jack.enable = true; # Personal user

  # Networking.
  networking.networkmanager.enable = true;
  networking.hostName = "virt01";

  # Fixes DNS not working after initrd
  # https://github.com/NixOS/nixpkgs/issues/63941#issuecomment-2081126437
  boot.initrd.network.udhcpc.enable = true;
  boot.initrd.network.flushBeforeStage2 = true;

  # SSH.
  coblelab.ssh.enable = true;

  # Disable sudo password for users in the "wheel" group
  security.sudo.wheelNeedsPassword = false;

  # Timezone.
  coblelab.timezone.enable = true;

  # System Packages
  environment.systemPackages = with pkgs; [
    sops
    age
    ssh-to-age
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
