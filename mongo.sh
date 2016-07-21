#!/bin/bash

BACKUP_NAME="$(date +%Y.%m.%d.%H%M%S)"
BACKUP_CMD="mongodump --archive=/backup/${BACKUP_NAME} --host mongo --port 27017"
echo ${BACKUP_CMD}
MAX_BACKUPS=${MAX_BACKUPS}

echo "=> Backup started"
if ${BACKUP_CMD} ;then
    echo "   Backup succeeded"

    if [[ -n "$S3_BACKUP" ]]; then
        echo "   Archiving and backing up dump to S3"

        echo "   Creating archive at /backup/${BACKUP_NAME}.tgz"
        tar czf "/backup/${BACKUP_NAME}.tgz" "/backup/${BACKUP_NAME}"

        echo "   Copying to S3"
        aws s3 cp "/backup/${BACKUP_NAME}.tgz" s3://$S3_BUCKET/$S3_PATH/${BACKUP_NAME}.tgz

        rm "/backup/${BACKUP_NAME}.tgz"
        if [ $? == 0 ]; then
            echo "   Uploaded /backup/${BACKUP_NAME}.tgz successfully to S3"
        else
            >&2 echo "couldn't transfer /backup/${BACKUP_NAME}.tgz to S3"
        fi
    fi
else
    echo "   Backup failed"
    rm -rf /backup/${BACKUP_NAME}
fi

if [[ -n "${MAX_BACKUPS}" ]]; then
    while [ $(ls /backup -N1 | wc -l) -gt ${MAX_BACKUPS} ];
    do
        BACKUP_TO_BE_DELETED=$(ls /backup -N1 | sort | head -n 1)
        echo "   Deleting backup ${BACKUP_TO_BE_DELETED}"
        rm -rf /backup/${BACKUP_TO_BE_DELETED}
    done
    while [ $(aws s3 ls s3://codepit/backups/mongo/ | tail -n+2 | wc -l) -gt ${MAX_BACKUPS} ];
    do
        BACKUP_TO_BE_DELETED=$(aws s3 ls s3://$S3_BUCKET/$S3_PATH/ | tail -n+2 | awk '{print $4}' | sort | head -n 1)
        echo "   Deleting backup ${BACKUP_TO_BE_DELETED} from S3"
        aws s3 rm s3://$S3_BUCKET/$S3_PATH/${BACKUP_TO_BE_DELETED}
    done
fi
echo "=> Backup done"