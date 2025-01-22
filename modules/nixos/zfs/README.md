# zfs

This module contains all the configuration for ZFS. I've settled on ZFS as my primary filesystem due to how it can preserve data integrity and provide snapshots. I'm still scratching the surface of ZFS, and would love to have an off-site host where I can send/receive snapshots as another backup method.

I currently use [Disko](https://github.com/nix-community/disko) to declare my partitions for ZFS on my boot drives. Previously, I did attempt to configure my primary storage pool using it, but I mistakenly ended up wiping it out when I made changes to the Disko config!

Until support for incremental changes within the Disko configuration is a bit more stable, I'll stick to just using it for my boot drives, and configuring my other storage pools manually.
