#!/usr/bin/zsh

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
cp -r $SCRIPT_DIR/_systemd $HOME/.config/containers/systemd/certbot
podman pull docker.io/certbot/dns-cloudflare:latest

mkdir $HOME/letsencrypt
systemctl --user daemon-reload
echo "Starting certbot installs. They have a built-in 30-second minimum wait, so be patient. First up is startcodon.com..."
systemctl --user start certbot-install@startcodon.com.service --wait
echo "Finished startcodon.com. Now for airbreather.party..."
systemctl --user start certbot-install@airbreather.party.service --wait
echo "All done"
