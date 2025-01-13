# CobleLab

## ⚡️ Features

- ❄️ Powered by [Nix flakes](https://nixos.wiki/wiki/Flakes)
- 💾 Powered by [OpenZFS](https://openzfs.org)
- 👻 Ephemeral root filesystem managed with [Impermanence](https://github.com/nix-community/impermanence)
- 🔓 Remote initrd unlock to decrypt LUKS drive on boot
- 🔑 Secrets management with [SOPS](https://getsops.io/) via [sops-nix](https://github.com/Mic92/sops-nix)
- 🛠️ Modular repository architecture for readability and usability
- 📦 [Custom made installation ISOs](https://github.com/jackcoble/coblelab/releases) (contains my SSH key)

## 🧱 Getting Started

To provision a system as fast as possible, I have created an [install.sh](https://github.com/jackcoble/coblelab/blob/main/install.sh) script which takes care of everything. This is highly tailored to my setup, so it will not work for you.

```bash
$ ./install.sh
```

## Manual Configuration

Once the base system has been installed, some manual steps need to be performed to complete the configuration. It is required to create a new [storage pool](https://openzfs.readthedocs.io/en/latest/introduction.html#storage-pools) where the majority of my data will reside.

For my current setup, I have 2 external SSDs plugged into my NUC. I will create a ZFS Pool which is encrypted, and is mirrored across both drives, giving me 1 drive as redundancy.

### Storage Pool

Pool Name: `zstorage`

SSD 1:

- Model: External Crucial X9 SSD (1TB)
- Identifier: `/dev/disk/by-id/usb-Micron_CT1000X9SSD9_2419E8D193A0-0:0`

SSD 2:

- Model: Crucial P2 CT1000P2SSD8 NVMe (1TB) (External USB-C Enclosure)
- Identifier: `/dev/disk/by-id/usb-SSK_SSK_Storage_DD564198838B8-0:0`

The encryption passphrase is supplied at `/run/secrets/zfs/master`

```
$ zpool create -o ashift=12 \
    -O encryption=on keylocation=file:///run/secrets/zfs/master keyformat=passphrase
    zstorage mirror /dev/disk/by-id/usb-Micron_CT1000X9SSD9_2419E8D193A0-0:0 /dev/disk/by-id/usb-SSK_SSK_Storage_DD564198838B8-0:0
```
