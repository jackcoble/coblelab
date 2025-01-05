/*
My public SSH Keys
*/
{
  /*
  Host keys are used for SSH verification and Secrets encryption

  Location: `/etc/ssh/ssh_host_ed25519_key`
  */
  host = {
    nuc01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKluNai/HHBa04m2d8fC9DWUtL4uohM60EKXcLMREFEm";
  };

  /*
  Boot keys are used for SSH verification that takes place during the boot process
  via initrd to decrypt LUKS partitions remotely

  Location: `/etc/ssh/ssh_boot_ed25519_key` (+ added to initrd)
  */
  boot = {
    nuc01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlvKKpxvgFlPCbQ9POtj4SBihPbVXPvC5f8BLRUwXne";
  };

  /*
  User keys are to authorise users for SSH access, and for Secrets encryption on the user level

  Location: `~/.ssh/id_ed25519.pub`
  */
  user = {
    jack = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBt423fvkSC8SeKVPPAl3MFpwvzwBZ8XEBd4/KrINoP jack@macbookair";
  };
}
