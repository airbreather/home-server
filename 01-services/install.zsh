#!/usr/bin/zsh

paru -S --needed podman crun
paru -D --asdeps crun

# get user prompting out of the way early
if ! $(podman secret exists cloudflare_credentials); then
    (read -s 'CLOUDFLARE_TOKEN?Cloudflare API token: '; echo "dns_cloudflare_api_token=$CLOUDFLARE_TOKEN" | podman secret create --replace cloudflare_credentials -)
fi

# common Podman-related stuff, not specific to any services
cat >/tmp/10-unqualified-search-registries.conf <<<'unqualified-search-registries = ["docker.io"]'
chmod 0644 /tmp/10-unqualified-search-registries.conf
sudo mv /tmp/10-unqualified-search-registries.conf /etc/containers/registries.conf.d/
mkdir -p $HOME/.config/containers/systemd
loginctl enable-linger

# handle each service now using its own install script
$PWD/archipelago/install.zsh
$PWD/certbot/install.zsh
