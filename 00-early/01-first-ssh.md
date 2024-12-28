# First SSH

This gets you into the chroot. The initial line is to help figure out which device to install to.

```sh
fdisk -l
device=/dev/vda
vared -p 'Root device: ' -r "[$device]" device
echo 'g\nn\n\n\n+1G\nt\n1\nn\n\n\n\nw' | fdisk $device
sync
mkfs.fat -F 32 -n ESP ${device}1
mkfs.btrfs -L MAIN ${device}2
mount ${device}2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@var_pacman_pkg
umount /mnt
mount -o subvol=@,compress=zstd ${device}2 /mnt
mount --mkdir ${device}1 /mnt/boot
mount --mkdir -o subvol=@home,compress=zstd ${device}2 /mnt/home
mount --mkdir -o subvol=@snapshots ${device}2 /mnt/.snapshots
mount --mkdir -o subvol=@var_log,compress=zstd ${device}2 /mnt/var/log
mount --mkdir -o subvol=@var_pacman_pkg ${device}2 /mnt/var/pacman/pkg
while systemctl show reflector | grep -q ActiveState=activating; do echo Waiting for Reflector to finish...; sleep 1s; done
echo Reflector finished
perl -pi -e 's/^#(?=(?:Color)|(?:ParallelDownloads = \d+)$)//' /etc/pacman.conf
pacstrap -PK /mnt base linux-lts dracut base-devel linux-lts-headers linux-firmware amd-ucode btrfs-progs emacs-nox git man-db man-pages texinfo openssh pacman-contrib dkms zsh devtools samba
genfstab -L /mnt >> /mnt/etc/fstab
ln -sf ../run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf
cut -f 2 -d: /etc/shadow | head -n1 > /mnt/etc/.root-password
arch-chroot /mnt
```

You're now in the chroot, so proceed to running the next step in there.
