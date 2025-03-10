# From chroot

Nothing too fancy here. There are plenty of heredocs below, but each is very small. Not worth worrying about.

```sh
cat >/root/.emacs <<<'(setq make-backup-files nil)'
ln -sf /usr/share/zoneinfo/America/Detroit /etc/localtime
systemctl enable systemd-timesyncd.service
hwclock --systohc
perl -pi -e 's/#(?=en_US\.UTF-8 UTF-8)//' /etc/locale.gen
locale-gen
cat >/etc/locale.conf <<<'LANG=en_US.UTF-8'
cat >/etc/hostname <<<'juan'
cat >/etc/systemd/network/20-wired.network <<END
[Match]
Name=en*

[Network]
DHCP=yes
END
systemctl enable systemd-networkd.service systemd-resolved.service
cat >/etc/dracut.conf.d/myflags.conf <<END
uefi="yes"
compress="zstd"
kernel_cmdline="root=LABEL=MAIN rootflags=subvol=@,compress=zstd"
END
for k in /usr/lib/modules/*; do dracut --kver $(basename "$k"); done
bootctl install
cat >/boot/loader/loader.conf <<END
timeout 0
console-mode keep
editor no
END
usermod -p `cat /etc/.root-password` root
useradd -m -G wheel,users -U -s /usr/bin/zsh -p `cat /etc/.root-password` joe
rm /etc/.root-password
cat >/etc/sudoers.d/00_wheel <<<'%wheel ALL=(ALL:ALL) ALL'
perl -pi -e 's/(?<=-march=x86-64) /-v3 / ; s/(?<=-mtune=)generic/native/ ; s/^#(RUSTFLAGS="[^"]*)"/$1 -C target-cpu=x86-64-v3"/ ; s/^#(?<prefix>MAKEFLAGS="-j)(\d+)(?<postfix>.*)$/$+{prefix}10$+{postfix}/' /etc/makepkg.conf
systemctl enable sshd.service paccache.timer
mkdir -m 0700 /home/joe/.ssh
cat >/home/joe/.ssh/authorized_keys <<<'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICCWGHWSbfrMaedEPJUZKoHKHKcowy2oKW2PIK8MUJ7P'
cat >/home/joe/.emacs <<<'(setq make-backup-files nil)'
touch /home/joe/.zshrc
chown -R joe:joe /home/joe/.ssh /home/joe/.emacs /home/joe/.zshrc
# https://gitlab.archlinux.org/archlinux/arch-install-scripts/-/issues/70
chmod 0644 /etc/pacman.conf
exit
```

This got you out of the chroot. Proceed to the next step.
