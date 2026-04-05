FROM node:20-slim

WORKDIR /app

# Install dependencies first (layer cache)
COPY teamdev-2026-slack/package.json teamdev-2026-slack/package-lock.json ./
RUN npm ci

# Copy source
COPY teamdev-2026-slack/tsconfig.json ./
COPY teamdev-2026-slack/src/ ./src/

CMD ["npx", "ts-node", "src/app.ts"]
