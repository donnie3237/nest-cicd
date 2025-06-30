# ---- Base Stage ----
FROM node:18-alpine AS base
# Install pnpm globally
RUN npm install -g pnpm
WORKDIR /usr/src/app
# Copy package definition and lock file
COPY package.json pnpm-lock.yaml* ./

# ---- Dependencies Stage ----
FROM base AS dependencies
# Install dependencies using pnpm based on the lock file
RUN pnpm install --frozen-lockfile

# ---- Build Stage ----
FROM dependencies AS builder
COPY . .
# The build script in package.json usually works with any manager
RUN npm run build

# ---- Production Stage ----
FROM base AS production
ENV NODE_ENV=production
# Copy dependencies from the 'dependencies' stage
COPY --from=dependencies /usr/src/app/node_modules ./node_modules
# Copy built artifacts from the 'builder' stage
COPY --from=builder /usr/src/app/dist ./dist
# Copy package.json for running the app
COPY --from=builder /usr/src/app/package.json ./package.json

# Port the app runs on (Default is 3000)
EXPOSE 3000

CMD [ "node", "dist/main" ]
