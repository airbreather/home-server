#!/usr/bin/zsh

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

if false; then
    systemctl --user is-active web-pod && systemctl --user stop web-pod
    podman image rm -f localhost/archipelago:latest
    podman image rm -f localhost/yarp:latest
    podman volume rm -f systemd-certbot-etc-letsencrypt
    for secret_name in "cloudflare_credentials" "postgresql_password" "archipelago_host" "forgejo_host" "jellyfin_host"; do
        podman secret rm -i $secret_name
    done
    rm -rf $HOME/.config/containers/systemd
    rm -rf $HOME/Archipelago/{externals,roms,worlds}
    systemctl --user daemon-reload
fi

paru -S --needed podman crun
paru -D --asdeps crun

# common Podman-related stuff, not specific to any services
cat >/tmp/10-unqualified-search-registries.conf <<<'unqualified-search-registries = ["docker.io"]'
chmod 0644 /tmp/10-unqualified-search-registries.conf
sudo mv /tmp/10-unqualified-search-registries.conf /etc/containers/registries.conf.d/
loginctl enable-linger
systemctl --user enable podman-auto-update.timer

# get user prompting out of the way early
if ! $(podman secret exists cloudflare_credentials); then
    (read -s 'CLOUDFLARE_TOKEN?Cloudflare API token: '; echo "dns_cloudflare_api_token=$CLOUDFLARE_TOKEN" | podman secret create cloudflare_credentials -)
fi
if ! $(podman secret exists postgresql_password); then
    (read -s 'POSTGRESQL_PASSWORD?PostgreSQL password: '; echo -n $POSTGRESQL_PASSWORD | podman secret create postgresql_password -)
fi
if ! $(podman secret exists archipelago_host); then
    (read -s 'ARCHIPELAGO_HOST?Archipelago host: '; echo -n $ARCHIPELAGO_HOST | podman secret create archipelago_host -)
fi
if ! $(podman secret exists forgejo_host); then
    (read -s 'FORGEJO_HOST?Forgejo host: '; echo -n $FORGEJO_HOST | podman secret create forgejo_host -)
fi
if ! $(podman secret exists jellyfin_host); then
    (read -s 'JELLYFIN_HOST?Jellyfin host: '; echo -n $JELLYFIN_HOST | podman secret create jellyfin_host -)
fi

mkdir -p $HOME/.config/containers/systemd
cp $SCRIPT_DIR/web.pod $HOME/.config/containers/systemd/

# handle old data. don't worry, this doesn't remap the UID/GID values in the zpool just yet.
$SCRIPT_DIR/handle-old-data.zsh

# handle each service now using its own install script. Certbot goes first so we can daemon-reload
# and set up the /etc/letsencrypt volume before any of the other containers (especially those that
# depend on it) get started.
$SCRIPT_DIR/certbot/install.zsh
echo "Starting certbot installs. They have a built-in 30-second minimum wait, so be patient. First up is startcodon.com..."
systemctl --user daemon-reload
systemctl --user start certbot-install@startcodon.com.service --wait
echo "Finished startcodon.com. Now for airbreather.party..."
systemctl --user start certbot-install@airbreather.party.service --wait
echo "Finished airbreather.party. Now for airbreather.dev..."
systemctl --user start certbot-install@airbreather.dev.service --wait
echo "Finished airbreather.dev. Moving onto install other services."

$SCRIPT_DIR/archipelago/install.zsh
$SCRIPT_DIR/forgejo/install.zsh
$SCRIPT_DIR/jellyfin/install.zsh
$SCRIPT_DIR/postgresql/install.zsh
$SCRIPT_DIR/samba/install.zsh
$SCRIPT_DIR/yarp/install.zsh

systemctl --user daemon-reload
systemctl --user enable --now web-pod.service
sudo systemctl enable --now smb.service

echo "Done."
