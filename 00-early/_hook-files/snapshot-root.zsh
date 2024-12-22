#!/usr/bin/zsh

# based on https://github.com/vaminakov/btrfs-autosnap
btrfs subvolume snapshot -r / "/.snapshots/root-auto/$(date -u --rfc-3339=ns)"
