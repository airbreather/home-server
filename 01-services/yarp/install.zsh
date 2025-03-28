#!/usr/bin/zsh

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

mkdir -p $HOME/.config/containers/systemd
cp $SCRIPT_DIR/../web.pod $HOME/.config/containers/systemd/
cp -r $SCRIPT_DIR/_systemd $HOME/.config/containers/systemd/yarp

mkdir $HOME/yarp-logs
