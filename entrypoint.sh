#!/bin/bash

if [ -n "${INIT_BACKUP}" ]; then
    echo "=> Create a backup on the startup"
    ./backup.sh
fi

# echo "=> Adding backup crontab entry"
# echo "${CRON_TIME} /backup.sh >> /mongo_sync.log 2>&1" >> /crontab.conf

# touch /mongo_sync.log
# tail -f /mongo_sync.log &
# crontab /crontab.conf
# echo "=> Running cron job"
# exec cron -f