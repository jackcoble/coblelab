/*
My public SSH Keys
*/
{
  /*
  Host keys are used for SSH verification and Secrets encryption

  Location: `/etc/ssh/ssh_host_ed25519_key`
  */
  host = {
    nuc01 = "";
  };

  /*
  Boot keys are used for SSH verification that takes place during the boot process
  via initrd to decrypt LUKS partitions remotely

  Location: `/etc/ssh/ssh_boot_ed25519_key` (+ added to initrd)
  */
  boot = {
    nuc01 = "";
  };

  /*
  User keys are to authorise users for SSH access, and for Secrets encryption on the user level

  Location: `~/.ssh/id_ed25519.pub`
  */
  user = {
    jack = "";
  };
}
