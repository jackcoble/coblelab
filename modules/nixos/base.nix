/*
This module contains the base configuration for NixOS.
It is included in all of my NixOS machines.
*/
{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: {
  # Localisation
  time.timeZone = "Europe/London";
  console.keyMap = "uk";
  i18n.defaultLocale = "en_GB.UTF-8";

  # Use systemd-boot as the bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 16; # Limits the number of boot entries (doesn't influence how many generations are kept during garbage collection though)
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3; # Reduce the timeout to 3 seconds, from 5 seconds (every second counts!)

  # Allow unfree packages (sorry, RMS!)
  nixpkgs.config.allowUnfree = true;

  # Experimental features
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Packages I want installed on all machines
  environment.systemPackages = with pkgs; [
    git
  ];

  # Tweaks to "sudo"
  # Only allow members of the "wheel" group to use sudo
  security.sudo.execWheelOnly = true;
}
