#!/usr/bin/zsh

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
cp -r $SCRIPT_DIR/_systemd $HOME/.config/containers/systemd/certbot
podman pull docker.io/certbot/dns-cloudflare:latest

# initial certs require more command-line params
# volume details all to match what's in _systemd for renew
# secrets are set up in the parent install script
mkdir $HOME/letsencrypt
for domain in 'startcodon.com' 'airbreather.party'; do
    podman run \
        --rm \
        -v "$HOME/letsencrypt:/etc/letsencrypt:Z" \
        -v "certbot-var-log-letsencrypt:/var/log/letsencrypt:Z" \
        -v "certbot-var-lib-letsencrypt:/var/lib/letsencrypt:Z" \
        --secret cloudflare_credentials,mode=0600 \
        docker.io/certbot/dns-cloudflare:latest \
            certonly \
            --email 'airbreather@linux.com' \
            --agree-tos \
            --non-interactive \
            --dns-cloudflare \
            --dns-cloudflare-credentials /run/secrets/cloudflare_credentials \
            --dns-cloudflare-propagation-seconds 30 \
            -d $domain \
            -d '*.'$domain
done
