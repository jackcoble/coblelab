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
    ];

    # Nix-darwin things...
    nix.enable = false;
    system.stateVersion = 6;
}