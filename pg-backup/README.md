# Postgres backup

Back up a PostgreSQL database to AWS S3.

## Usage

```shell
$ docker run \
  -e AWS_ACCESS_KEY_ID=key-id \
  -e AWS_SECRET_ACCESS_KEY=secret-key \
  -e S3_BUCKET=bucket-name \
  -e POSTGRESQL_DATABASE=db_name \
  -e POSTGRESQL_USER=user \
  -e POSTGRESQL_PASSWORD=p4ssw0rd \
  -e POSTGRES_HOST=localhost \
  outtherelabs/pg-backup
```
