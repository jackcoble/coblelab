# CobleLab

## ⚡️ Features

- ❄️ Powered by [Nix flakes](https://nixos.wiki/wiki/Flakes)
- 👻 Ephemeral root filesystem powered by ZFS snapshots, and managed with [Impermanence](https://github.com/nix-community/impermanence)
- 🔓 Remote initrd unlock to decrypt LUKS drive on boot
- 🔑 Secrets management with [SOPS](https://getsops.io/) via [sops-nix](https://github.com/Mic92/sops-nix)
- 🛠️ Modular repository architecture for readability and usability
- 📦 [Custom made installation ISOs](https://github.com/jackcoble/coblelab/releases) (contains my SSH key)

## 🧱 Getting Started

To provision a system as fast as possible, I have created an [install.sh](https://github.com/jackcoble/coblelab/blob/main/install.sh) script which takes care of everything. This is highly tailored to my setup, so it will not work for you.

```bash
$ ./install.sh
```
