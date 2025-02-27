<h1 align="center">CobleLab</h1>
<p align="center">My personal NixOS flake for all of my systems and servers.</h1>
<div align="center">
    <img src="https://img.shields.io/badge/NIXOS-5277C3.svg?style=for-the-badge&logo=NixOS&logoColor=white" />
    <img src="https://img.shields.io/badge/NixOS-24.11-blue?style=for-the-badge&logo=nixos&logoColor=white" />
    <a href="https://github.com/jackcoble/coblelab/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/jackcoble/coblelab?style=for-the-badge" />
    </a>
</div>

## ⚡️ Features

- ❄️ Powered by [Nix flakes](https://nixos.wiki/wiki/Flakes)
- 💾 Powered by [OpenZFS](https://openzfs.org)
- 👻 Ephemeral root filesystem managed with [Impermanence](https://github.com/nix-community/impermanence)
- 🔑 Secrets management with [SOPS](https://getsops.io/) via [sops-nix](https://github.com/Mic92/sops-nix)
- 🛠️ Modular repository architecture for readability and usability
- 📦 [Custom made installation ISOs](https://github.com/jackcoble/coblelab/releases) (contains my SSH key)

## 🤖 Machines

- `nuc01` - Beelink MINI S12 (NUC)

## 🧱 Getting Started

To provision a system as fast as possible, I have created an [install.sh](https://github.com/jackcoble/coblelab/blob/main/install.sh) script which takes care of everything. This is highly tailored to my setup, so it will not work for you.

```bash
$ ./install.sh
```

Once the installation is completed, I can SSH into the machine with my personal user, and then bring my system up to date with my changes. (Make sure git is installed!)

```bash
# nixos-rebuild switch --flake git+https://github.com/jackcoble/coblelab --refresh
```

## Manual Configuration

Once the base system has been installed, some manual steps need to be performed to complete the configuration. It is required to create a new [storage pool](https://openzfs.readthedocs.io/en/latest/introduction.html#storage-pools) where the majority of my data will reside.


### Storage Pools

| Pool Name | RAID Type | Device Identifiers                                                                                                    | Purpose                                       | Raw Storage | Actual Storage |
| --------- | --------- | --------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- | ----------- | -------------- |
| zflash  | Mirror    | `/dev/disk/by-id/usb-Micron_CT1000X9SSD9_2419E8D193A0-0:0`<br>`/dev/disk/by-id/usb-SSK_SSK_Storage_DD564198838B8-0:0` | Primary storage pool for data with redundancy | 2 TB        | 1 TB           |

```
$ zpool create -o ashift=12 \
    zflash mirror /dev/disk/by-id/usb-Micron_CT1000X9SSD9_2419E8D193A0-0:0 /dev/disk/by-id/usb-SSK_SSK_Storage_DD564198838B8-0:0
```
