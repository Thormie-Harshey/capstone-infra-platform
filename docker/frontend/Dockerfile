# Stage 1: prepare the page and stamp the version number
FROM alpine:3.21 AS builder
ARG APP_VERSION=1.0.0
WORKDIR /site
COPY index.html .
RUN sed -i "s/__VERSION__/${APP_VERSION}/" index.html

# Stage 2: serve it with non-root nginx
FROM nginxinc/nginx-unprivileged:1.27-alpine
COPY --from=builder /site/index.html /usr/share/nginx/html/index.html
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost:8080/ > /dev/null || exit 1