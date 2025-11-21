#!/bin/bash

start_backup () {
  PGHOST=127.0.0.1 /usr/local/bin/wal-g backup-push $1

  if [ $? -eq 0 ]
  then
    /opt/postgres/bin/notification.sh "backup-push" "primary" $PATRONI_SCOPE
    exit 0
  else
    /opt/postgres/bin/notification.sh "backup-error" "primary" $PATRONI_SCOPE
    exit 1
  fi
}

# find the primary db
primary=`curl --silent http://$ARCHIVE_ETCD_HOST/v2/keys/service/$PATRONI_SCOPE/leader | jq -r .node.value`

# run the backup if primary
if [ $primary = $PATRONI_NAME ]
then
  echo "I'm a primary node, starting backup"
  start_backup $PGDATA
else
  echo "Not a primary node, I can perform backups only at primary node"
  exit 0
fi
