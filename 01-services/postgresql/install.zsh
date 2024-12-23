#!/usr/bin/zsh

if ! $(podman secret exists postgresql_password); then
    (read -s 'POSTGRESQL_PASSWORD?PostgreSQL password: '; echo $POSTGRESQL_PASSWORD | podman secret create postgresql_password -)
fi

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

mkdir -p $HOME/.config/containers/systemd
cp -r $SCRIPT_DIR/_systemd $HOME/.config/containers/systemd/postgresql

systemctl --user daemon-reload
