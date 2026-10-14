# Hub-only image. The hub is plain Node with no tokscale binary:
# `npm run hub` is `node src/hub/server.js` and never downloads anything.
FROM docker.io/library/node:22-slim

ENV NODE_ENV=production

WORKDIR /app

# Install production dependencies first for better layer caching.
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund \
  && npm cache clean --force

# Hub runtime is src/hub/server.js + src/shared/.
COPY src ./src

# curl is only used for the container HEALTHCHECK.
RUN apt-get update \
  && apt-get install -y --no-install-recommends curl \
  && rm -rf /var/lib/apt/lists/*

# Writable store for devices.json (see TOKEN_MONITOR_DATA_FILE below).
RUN mkdir -p /app/data && chown -R node:node /app
USER node

ENV TOKEN_MONITOR_PORT=17321 \
    TOKEN_MONITOR_HOST=0.0.0.0 \
    TOKEN_MONITOR_DATA_FILE=/app/data/devices.json

EXPOSE 17321
VOLUME /app/data

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f "http://127.0.0.1:${TOKEN_MONITOR_PORT:-17321}/api/health" || exit 1

CMD ["node", "src/hub/server.js"]
