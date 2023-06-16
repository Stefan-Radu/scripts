# !/bin/bash

if [[ -d "/media/backup" ]]; then
    echo "Drive mounted. Running backup..."
    rsync -av --delete --progress --log-file=/home/$(whoami)/Desktop/backup.log --exclude="Movies" --exclude=".vbox" --exclude=".cache" /home/$(whoami) /media/backup/
    chown $(whoami):wheel /home/$(whoami)/Desktop/backup.log
else
    echo "Drive not mounted."
fi
