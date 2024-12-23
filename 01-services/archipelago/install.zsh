#!/usr/bin/zsh

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

mkdir -p $HOME/.config/containers/systemd
cp -r $SCRIPT_DIR/_systemd $HOME/.config/containers/systemd/archipelago

mkdir -p $HOME/Archipelago
pushd $HOME/Archipelago

# mapped to custom_worlds
rm -rf worlds
mkdir worlds

# all 'rom_file' and 'something_rom_file' in host.yaml look here for it:
rm -rf roms
mkdir roms

# some external tools that certain Archipelago worlds specifically use:
rm -rf externals
mkdir externals
pushd externals

# SNI (untested)
curl -o /tmp/sni-v0.0.99-linux-amd64.tar.xz -L https://github.com/alttpo/sni/releases/download/v0.0.99/sni-v0.0.99-linux-amd64.tar.xz
sha256sum -c <<<'b06513bce0d44c607e3b3f5548a8ce2b28e10bb41d6773276bc19ce84f6087b6  /tmp/sni-v0.0.99-linux-amd64.tar.xz' || exit 1
tar -xf /tmp/sni-v0.0.99-linux-amd64.tar.xz
rm /tmp/sni-v0.0.99-linux-amd64.tar.xz
mv sni-v0.0.99-linux-amd64 SNI

# Enemizer (untested)
curl -o /tmp/ubuntu.16.04-x64.zip -L https://github.com/Ijwu/Enemizer/releases/download/7.1/ubuntu.16.04-x64.zip
sha256sum -c <<<'efab6784cbfe4189a01e0e25226943afd7f71e7c2f10f74b88bfa34fdac972ab  /tmp/ubuntu.16.04-x64.zip' || exit 1
unzip /tmp/ubuntu.16.04-x64.zip -d EnemizerCLI
rm /tmp/ubuntu.16.04-x64.zip

popd

# Probably the easiest way to ensure that the mapped users have what they need.
chmod -R o+r worlds roms externals

popd

systemctl --user daemon-reload
