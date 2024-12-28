#!/usr/bin/zsh

if false; then
    for i in {1..5}; do fallocate -l 1G ~/$i.img; done
    sudo zpool create nas raidz1 ~/{1,2,3,4,5}.img
    for f in joe kristina media shared archipelago forgejo foundryvtt foundryvtt2 archipelago2 factorio20241027
    do
        sudo zfs create -o compression=zstd nas/$f
        sudo touch /nas/$f/some-file-owned-by-$f
    done
    sudo chown -R 1000:1000 /nas/joe
    sudo chown -R 1002:1002 /nas/kristina
    sudo chown -R 1004:1004 /nas/factorio20241027
    sudo chown -R 0:984 /nas/media
    sudo chown -R 969:969 /nas/archipelago
    sudo chown -R 963:963 /nas/forgejo
    sudo chown -R 968:984 /nas/foundryvtt
    sudo chown -R 966:966 /nas/foundryvtt2
    sudo chown -R 967:967 /nas/archipelago2
    sudo mkdir -p /nas/media/jellyfin
    sudo chown 971:971 /nas/media/jellyfin
fi
sudo systemctl enable --now zfs.target zfs-import.target zfs-import-cache.service zfs-mount.service zfs-zed.service
sudo touch /etc/zfs/zfs-list.cache/nas

# easier now because almost everything is going to be owned by my user outside the container.
echo '#!/usr/bin/sh' >/home/joe/remap_ids.sh
joe_uid=$(id -u joe)
kristina_uid=$(id -u kristina)

echo find /nas -uid 1002 -exec chown --no-dereference $kristina_uid "'{}'" "';'" >> /home/joe/remap_ids.sh
for old_uid in 198 962 963 965 966 967 968 969 971 994 1000 1003 1004 
do
    echo find /nas -uid $old_uid -exec chown --no-dereference $joe_uid "'{}'" "';'" >> /home/joe/remap_ids.sh
done

joe_gid=$(getent group joe | cut -d: -f3)
users_gid=$(getent group users | cut -d: -f3)
kristina_gid=$(getent group kristina | cut -d: -f3)

echo find /nas -gid 984 -exec chgrp --no-dereference $users_gid "'{}'" "';'" >> /home/joe/remap_ids.sh
echo find /nas -gid 1002 -exec chgrp --no-dereference $kristina_gid "'{}'" "';'" >> /home/joe/remap_ids.sh
for old_gid in 198 961 962 963 965 966 967 968 969 971 994 1000 1004
do
    echo find /nas -gid $old_gid -exec chgrp --no-dereference $joe_gid "'{}'" "';'" >> /home/joe/remap_ids.sh
done
echo
echo
echo
echo 'A script has been created at /home/joe/remap_ids.sh that will remap the IDs in the zpool.'
echo 'This is a DESTRUCTIVE operation, so I am taking full precautions not to run it automatically.'
echo 'Examine it before running it (which must be done as root). Good luck.'
```
