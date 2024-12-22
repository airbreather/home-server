#!/usr/bin/zsh

kvers=($(basename -a /usr/lib/modules/*))
for img in /boot/EFI/Linux/linux-*.efi
do
    kver_img=$(basename $img)
    found=0
    for kver in $kvers
    do
        if [[ $kver_img = "linux-$kver-"* ]]
        then
            found=1
            break
        fi

        if [[ $found = 0 ]]
        then
            mv $img /.snapshots/backup-efi/
        fi
    done
done

for kver in $kvers
do
    dracut --force --kver $kver
done
