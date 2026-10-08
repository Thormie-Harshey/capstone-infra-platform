FROM postgres:16-alpine3.21

# Scripts in this folder run only on first start (empty storage)
COPY init.sql /docker-entrypoint-initdb.d/01-init.sql

USER postgres

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD pg_isready -U "${POSTGRES_USER:-postgres}" || exit 1