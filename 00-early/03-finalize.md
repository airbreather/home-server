# Finalize

A lot of quick switches around here. You're still in the live system, so let's fix that first.

```sh
umount -R /mnt
reboot
```

Once it's rebooted, SSH in as 'joe'. There should be no password. Then:

```sh
curl -o install-omz.sh -L https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
echo 96d90bb5cfd50793f5666db815c5a2b0f209d7e509049d3b22833042640f2676 install-omz.sh | sha256sum -c - || exit 1
sh install-omz.sh
rm install-omz.sh
perl -pi -e 's/(?<=ZSH_THEME=")robbyrussell(?=")/strug/ ; s/# (?=(?:HYPHEN_INSENSITIVE="true")|(?:COMPLETION_WAITING_DOTS="true")|(?:DISABLE_MAGIC_FUNCTIONS="true"))//' $HOME/.zshrc
cat >$HOME/.oh-my-zsh/custom/prefs.zsh <<END
export EDITOR=/usr/bin/emacs
export DIFFPROG=/usr/bin/meld
setopt appendhistory
setopt INC_APPEND_HISTORY
END
```

Fully log out and then back in again one more time.

```sh
# yo dawg
mkdir $HOME/setup
pushd $HOME/setup
git clone https://github.com/airbreather/home-server.git .
sudo cp 00-early/_hook-files/*.hook /etc/pacman.d/hooks/
sudo cp 00-early/_hook-files/*.sh /usr/local/bin/
popd
mkdir -p $HOME/src/paru-bin
pushd $HOME/src/paru-bin
git clone https://aur.archlinux.org/paru-bin .
makepkg -si
popd
sudo perl -pi -e 's/#(?=SudoLoop)//' /etc/paru.conf
paru -S zfs-dkms
sudo mkdir -p /etc/zfs/zfs-list.cache
sudo systemctl enable --now zfs.target zfs-import.target zfs-import-cache.service zfs-mount.service zfs-zed.service
sudo touch /etc/zfs/zfs-list.cache/nas
sudo mkdir /.snapshots/backup-efi
sudo mkdir /.snapshots/root-auto
sudo useradd -G users -U -m kristina
```
