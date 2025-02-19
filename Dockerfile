# Use a specific Node.js version for better reproducibility
FROM node:18-slim

WORKDIR /app

# Installer pnpm
RUN npm install -g pnpm

# Copier les fichiers de configuration
COPY package.json pnpm-lock.yaml ./
COPY characters ./characters

# Installer les dépendances
RUN pnpm install --frozen-lockfile

# Copier le reste des fichiers
COPY . .

# Build
RUN pnpm build

# Commande de démarrage
CMD ["pnpm", "start", "--characters=characters/vrap.character.json"]
