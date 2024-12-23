#!/usr/bin/zsh

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# paru -S --needed podman crun
# paru -D --asdeps crun

# get user prompting out of the way early
if ! $(podman secret exists cloudflare_credentials); then
    (read -s 'CLOUDFLARE_TOKEN?Cloudflare API token: '; echo "dns_cloudflare_api_token=$CLOUDFLARE_TOKEN" | podman secret create cloudflare_credentials -)
fi
if ! $(podman secret exists postgresql_password); then
    (read -s 'POSTGRESQL_PASSWORD?PostgreSQL password: '; echo $POSTGRESQL_PASSWORD | podman secret create postgresql_password -)
fi

# common Podman-related stuff, not specific to any services
cat >/tmp/10-unqualified-search-registries.conf <<<'unqualified-search-registries = ["docker.io"]'
chmod 0644 /tmp/10-unqualified-search-registries.conf
sudo mv /tmp/10-unqualified-search-registries.conf /etc/containers/registries.conf.d/
loginctl enable-linger

# TESTING ONLY
# TESTING ONLY
# TESTING ONLY
# TESTING ONLY
# TESTING ONLY
rm -rf $HOME/.config/containers/systemd
systemctl --user daemon-reload
podman container stop -a
podman volume rm -a
# TESTING ONLY
# TESTING ONLY
# TESTING ONLY
# TESTING ONLY
# TESTING ONLY
# TESTING ONLY
# TESTING ONLY

mkdir -p $HOME/.config/containers/systemd
cp $SCRIPT_DIR/web.pod $HOME/.config/containers/systemd/

# handle each service now using its own install script
$SCRIPT_DIR/archipelago/install.zsh
# $SCRIPT_DIR/certbot/install.zsh
$SCRIPT_DIR/forgejo/install.zsh
$SCRIPT_DIR/jellyfin/install.zsh
$SCRIPT_DIR/postgresql/install.zsh

systemctl --user daemon-reload
systemctl --user start web-pod.service
