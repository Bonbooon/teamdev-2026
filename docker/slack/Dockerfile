FROM node:20-slim

WORKDIR /app

# Install dependencies first (layer cache)
COPY package.json package-lock.json ./
RUN npm ci

# Copy source
COPY tsconfig.json ./
COPY src/ ./src/

CMD ["npx", "ts-node", "src/app.ts"]
