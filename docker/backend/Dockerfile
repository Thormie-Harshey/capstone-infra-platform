# Stage 1: builder (the kitchen, has npm)
FROM node:22-alpine3.21 AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY server.js ./

# Stage 2: runtime (the delivery box, Node.js only)
FROM alpine:3.21
RUN apk add --no-cache nodejs \
 && addgroup -S app && adduser -S app -G app
WORKDIR /app
COPY --from=builder /app ./
USER app
ENV NODE_ENV=production PORT=3000
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/api/health/live || exit 1
CMD ["node", "server.js"]