#!/bin/bash
set -euo pipefail

if [ "${AWS_ACCESS_KEY_ID}" = "**None**" ]; then
  echo "You need to set the AWS_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ "${AWS_SECRET_ACCESS_KEY}" = "**None**" ]; then
  echo "You need to set the AWS_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ "${S3_BUCKET}" = "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ "${POSTGRESQL_DATABASE}" = "**None**" ]; then
  echo "You need to set the POSTGRESQL_DATABASE environment variable."
  exit 1
fi

if [ "${POSTGRESQL_HOST}" = "**None**" ]; then
  echo "You need to set the POSTGRESQL_HOST environment variable."
  exit 1
fi

if [ "${POSTGRESQL_USER}" = "**None**" ]; then
  echo "You need to set the POSTGRESQL_USER environment variable."
  exit 1
fi

if [ "${POSTGRESQL_PASSWORD}" = "**None**" ]; then
  echo "You need to set the POSTGRESQL_PASSWORD environment variable."
  exit 1
fi

export PGPASSWORD=$POSTGRESQL_PASSWORD
POSTGRESQL_CONNECTION_OPTS="-h $POSTGRESQL_HOST -p $POSTGRESQL_PORT -U $POSTGRESQL_USER $POSTGRESQL_EXTRA_OPTS"

if [ "${BACKUP_FILE_NAME}" = "latest" ]; then
  BACKUP_FILE_NAME=$(aws s3 ls s3://$S3_BUCKET/$S3_PATH | sort | tail -n 1 | awk '{ print $4 }')
fi
echo "Getting db backup ${BACKUP_FILE_NAME} from S3"

aws s3 cp s3://$S3_BUCKET/$S3_PATH${BACKUP_FILE_NAME} /var/restore/dump.sql.gz
gzip -d /var/ressstore/dump.sql.gz

if [ "${DROP_PUBLIC}" == "yes" ]; then
	echo "Recreating the public schema"
	psql $POSTGRES_HOST_OPTS -d $POSTGRES_DATABASE -c "drop schema public cascade; create schema public;"
fi

echo "Restoring ${BACKUP_FILE_NAME}"

psql $POSTGRESQL_CONNECTION_OPTS -d $POSTGRES_DATABASE < /var/restore/dump.sql

echo "Restore complete"
