#!/usr/bin/zsh

if ! $(podman secret exists forgejo_host); then
    (read -s 'FORGEJO_HOST?Forgejo host: '; echo $FORGEJO_HOST | podman secret create forgejo_host -)
fi
if ! $(podman secret exists jellyfin_host); then
    (read -s 'JELLYFIN_HOST?Jellyfin host: '; echo $JELLYFIN_HOST | podman secret create jellyfin_host -)
fi

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

mkdir -p $HOME/.config/containers/systemd
cp $SCRIPT_DIR/../web.pod $HOME/.config/containers/systemd/
cp -r $SCRIPT_DIR/_systemd $HOME/.config/containers/systemd/yarp

systemctl --user daemon-reload
