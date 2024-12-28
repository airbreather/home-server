#!/usr/bin/zsh

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

rm -rf $HOME/.config/containers/systemd/foundryvtt

mkdir -p $HOME/.config/containers/systemd
cp -r $SCRIPT_DIR/_systemd $HOME/.config/containers/systemd/foundryvtt
