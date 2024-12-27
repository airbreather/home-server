#!/usr/bin/zsh

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

paru -S --needed podman crun
paru -D --asdeps crun

# common Podman-related stuff, not specific to any services
cat >/tmp/10-unqualified-search-registries.conf <<<'unqualified-search-registries = ["docker.io"]'
chmod 0644 /tmp/10-unqualified-search-registries.conf
sudo mv /tmp/10-unqualified-search-registries.conf /etc/containers/registries.conf.d/
loginctl enable-linger
sudo sysctl net.ipv4.ip_unprivileged_port_start=443

# get user prompting out of the way early
if ! $(podman secret exists cloudflare_credentials); then
    (read -s 'CLOUDFLARE_TOKEN?Cloudflare API token: '; echo "dns_cloudflare_api_token=$CLOUDFLARE_TOKEN" | podman secret create cloudflare_credentials -)
fi
if ! $(podman secret exists postgresql_password); then
    (read -s 'POSTGRESQL_PASSWORD?PostgreSQL password: '; echo $POSTGRESQL_PASSWORD | podman secret create postgresql_password -)
fi
if ! $(podman secret exists forgejo_host); then
    (read -s 'FORGEJO_HOST?Forgejo host: '; echo $FORGEJO_HOST | podman secret create forgejo_host -)
fi
if ! $(podman secret exists jellyfin_host); then
    (read -s 'JELLYFIN_HOST?Jellyfin host: '; echo $JELLYFIN_HOST | podman secret create jellyfin_host -)
fi

mkdir -p $HOME/.config/containers/systemd
cp $SCRIPT_DIR/web.pod $HOME/.config/containers/systemd/

# handle each service now using its own install script
$SCRIPT_DIR/archipelago/install.zsh
$SCRIPT_DIR/certbot/install.zsh
$SCRIPT_DIR/forgejo/install.zsh
$SCRIPT_DIR/jellyfin/install.zsh
$SCRIPT_DIR/postgresql/install.zsh
$SCRIPT_DIR/yarp/install.zsh

systemctl --user daemon-reload
systemctl --user start web-pod.service
