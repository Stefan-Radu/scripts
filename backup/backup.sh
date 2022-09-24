# !/bin/bash

if [[ -d "/media/backup" ]]; then
    echo "Drive mounted. Running backup..."
    rsync -av --delete --progress --log-file=/home/stef/Desktop/backup.log --exclude="Movies" --exclude=".vbox" --exclude=".cache" /home/stef /media/backup/
    chown stef:wheel /home/stef/Desktop/backup.log
else
    echo "Drive not mounted."
fi
