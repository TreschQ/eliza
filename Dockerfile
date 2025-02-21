# Étape de build
FROM node:23.3.0-slim AS builder

# Installation de pnpm et des outils nécessaires
RUN npm install -g pnpm@9.15.4 && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    python3 \
    make \
    g++ \
    build-essential \
    libssl-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copie des fichiers nécessaires
COPY package.json pnpm-lock.yaml ./
COPY patches ./patches
COPY pnpm-workspace.yaml ./

# Installation des dépendances sans patch
RUN pnpm install --no-frozen-lockfile

# Copie du reste des fichiers
COPY . .

# Build
RUN pnpm build && pnpm prune --prod

# Image finale
FROM node:23.3.0-slim

# Installation des dépendances runtime minimales
RUN npm install -g pnpm@9.15.4 && \
    apt-get update && \
    apt-get install -y python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copie des fichiers depuis l'étape de build
COPY --from=builder /app/package.json ./
COPY --from=builder /app/pnpm-workspace.yaml ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/characters ./characters

# Commande de démarrage
CMD ["pnpm", "start", "--characters=characters/vrap.character.json"]
