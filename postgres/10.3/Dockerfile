FROM postgres:10.3-alpine

ENV POSTGRES_DB_PORT=${POSTGRES_DB_PORT:-5432} \
    DSPACE_DB_NAME=${DSPACE_DB_NAME:-dspace} \
    DSPACE_DB_USER=${DSPACE_DB_USER:-dspace} \
    DSPACE_DB_PASS=${DSPACE_DB_PASS:-""}

USER root

RUN apk --update --no-cache add postgresql-client postgresql-contrib

ADD init-dspace.sh /docker-entrypoint-initdb.d

RUN chmod 555 /docker-entrypoint-initdb.d/init-dspace.sh

USER postgres