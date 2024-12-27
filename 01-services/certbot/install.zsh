#!/usr/bin/zsh

if ! $(podman secret exists cloudflare_credentials); then
    (read -s 'CLOUDFLARE_TOKEN?Cloudflare API token: '; echo "dns_cloudflare_api_token=$CLOUDFLARE_TOKEN" | podman secret create cloudflare_credentials -)
fi

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
mkdir -p $HOME/.config/containers/systemd
cp -r $SCRIPT_DIR/_systemd $HOME/.config/containers/systemd/certbot
systemctl --user daemon-reload

echo "Starting certbot installs. They have a built-in 30-second minimum wait, so be patient. First up is startcodon.com..."
systemctl --user start certbot-install@startcodon.com.service --wait
echo "Finished startcodon.com. Now for airbreather.party..."
systemctl --user start certbot-install@airbreather.party.service --wait
echo "Finished airbreather.party. Now for airbreather.dev..."
systemctl --user start certbot-install@airbreather.dev.service --wait
