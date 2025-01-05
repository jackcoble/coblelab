{
  imports = [
    ./jack.nix
  ];

  # Users should not be mutable, they are managed entirely from configuration.
  users.mutableUsers = false;
}
