# CobleLab

## ⚡️ Features

- ❄️ Powered by [Nix flakes](https://nixos.wiki/wiki/Flakes)
- 👻 Ephemeral root filesystem powered by tmpfs, and managed with [Impermanence](https://github.com/nix-community/impermanence)
- 🧈 [BTRFS](https://docs.kernel.org/filesystems/btrfs.html) filesystem for persistent data
- 🔓 Remote initrd unlock to decrypt LUKS drives on boot
- 🔑 Secrets management with [SOPS](https://getsops.io/) via [sops-nix](https://github.com/Mic92/sops-nix)
- 🛠️ Modular repository architecture for readability and usability
- 📦 [Custom made installation ISOs](https://github.com/jackcoble/coblelab/releases) (contains my SSH key)

## 🧱 Getting Started

To provision a system as fast as possible, I have created an [install.sh](https://github.com/jackcoble/coblelab/blob/main/install.sh) script which takes care of everything. This is highly tailored to my setup, so it will not work for you.

```bash
$ ./install.sh
```
