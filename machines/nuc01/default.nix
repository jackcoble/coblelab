{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking.
  networking.networkmanager.enable = true;
  networking.hostName = "nuc01";

  # Set Time Zone.
  time.timeZone = "Europe/London";

  # Configure console keymap.
  console.keyMap = "uk";

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Experimental features.
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    git
  ];

  # Enable OpenSSH.
  services.openssh.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
