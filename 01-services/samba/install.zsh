#!/usr/bin/zsh

# too much insanity to containerize.
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

sudo cp $SCRIPT_DIR/smb.conf /etc/samba/smb.conf
sudo mkdir -p /var/lib/samba/usershares
sudo chmod +t /var/lib/samba/usershares
sudo zfs set sharesmb=on nas
