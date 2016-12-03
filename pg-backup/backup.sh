#! /bin/sh
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

echo "Creating dump of ${POSTGRESQL_DATABASE} database from ${POSTGRESQL_HOST}..."
pg_dump $POSTGRESQL_CONNECTION_OPTS $POSTGRESQL_DATABASE | gzip > dump.sql.gz

echo "Uploading dump to $S3_BUCKET"
cat dump.sql.gz | aws s3 cp - s3://$S3_BUCKET/$S3_PATH/$(date +"%Y-%m-%dT%H:%M:%SZ").sql.gz || exit 2

echo "SQL backup uploaded successfully"
