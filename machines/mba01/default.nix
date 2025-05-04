{
    inputs,
    pkgs,
    lib,
    ... 
}: {
    # Packages
    environment.systemPackages = with pkgs; [
      go
      docker
      docker-compose
      discord
    ];

    # Finder
    system.defaults.finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      NewWindowTarget = "Home";
    };

    # Nix-darwin things...
    nix.enable = false;
    system.stateVersion = 6;
}