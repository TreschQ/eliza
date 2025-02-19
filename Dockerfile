# Use a specific Node.js version for better reproducibility
FROM node:18-slim

WORKDIR /app

# Installer pnpm de manière plus fiable
RUN npm install -g pnpm@8.15.1

# Copier d'abord uniquement les fichiers nécessaires pour l'installation
COPY package.json ./
COPY pnpm-lock.yaml ./

# Installer les dépendances avec plus de verbosité
RUN pnpm install --no-frozen-lockfile

# Copier le reste des fichiers
COPY . .

# Build
RUN pnpm build

# Commande de démarrage
CMD ["pnpm", "start", "--characters=characters/vrap.character.json"]
