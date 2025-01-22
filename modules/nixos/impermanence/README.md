# impermanence

Ever since discovering [Graham Christensen's post](https://grahamc.com/blog/erase-your-darlings/) about having a clean system on each boot, I was fascinated with the idea.

I've decided to implement it on my systems with ZFS rollbacks and the [impermanence](https://github.com/nix-community/impermanence) module.

If this module is enabled, it will revert the root filesystem to a blank slate on every reboot. Files which need persisting can be configured in this module.
