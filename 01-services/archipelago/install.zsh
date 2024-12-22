#!/usr/bin/zsh

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

podman build -f $SCRIPT_DIR/Containerfile \
    --userns=host \
    --build-arg=python_version=3.12 \
    --build-arg=archipelago_tag=0.5.1.Hotfix1 \
    -t localhost/archipelago:0.5.1.Hotfix1

cp -r $SCRIPT_DIR/_systemd $HOME/.config/containers/systemd/archipelago

mkdir -p $HOME/archipelago
pushd $HOME/archipelago

# custom_worlds
mkdir custom_worlds

# SNI (untested)
curl -o /tmp/sni-v0.0.99-linux-amd64.tar.xz -L https://github.com/alttpo/sni/releases/download/v0.0.99/sni-v0.0.99-linux-amd64.tar.xz
sha256sum -c <<<'b06513bce0d44c607e3b3f5548a8ce2b28e10bb41d6773276bc19ce84f6087b6  /tmp/sni-v0.0.99-linux-amd64.tar.xz' || exit 1
tar -xf /tmp/sni-v0.0.99-linux-amd64.tar.xz

# Enemizer (untested)
curl -o ubuntu.16.04-x64.zip -L https://github.com/Ijwu/Enemizer/releases/download/7.1/ubuntu.16.04-x64.zip
sha256sum -c <<<'efab6784cbfe4189a01e0e25226943afd7f71e7c2f10f74b88bfa34fdac972ab  ubuntu.16.04-x64.zip' || exit 1
unzip ubuntu.16.04-x64.zip -d Enemizer-7.1

popd
