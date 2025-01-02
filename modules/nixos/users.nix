/*
Configuration for my users
*/
{...}: {
  users = {
    mutableUsers = false; # Users cannot be changed after the system is built

    users = {
      jack = {
        description = "Jack Coble";
        isNormalUser = true;
        extraGroups = [
          "wheel" # For sudo
        ];

        # password can be hashed with: nix run nixpkgs#mkpasswd -- -m SHA-512 -s
        hashedPassword = "$6$.PJlfWhD9B2mTh9E$NOI/Jr1rx9EHQ3aXLAL1wq.hacA1AsG1mj8m.5GVdjosC8XzHerkB6AAo1TeVi1.nv.LWv/iKmh5/UGOORGb40";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBt423fvkSC8SeKVPPAl3MFpwvzwBZ8XEBd4/KrINoP" # M3 Macbook Air
        ];
      };
    };
  };
}
