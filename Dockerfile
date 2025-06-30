# ---- Base Stage ----
FROM node:18-alpine AS base
WORKDIR /usr/src/app
COPY package*.json ./

# ---- Dependencies Stage ----
FROM base AS dependencies
RUN npm ci

# ---- Build Stage ----
FROM dependencies AS builder
COPY . .
RUN npm run build

# ---- Production Stage ----
FROM base AS production
ENV NODE_ENV=production
# สำหรับ NestJS ที่ใช้ `npm ci` ใน production ควร copy node_modules ทั้งหมด
COPY --from=dependencies /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/package.json ./package.json

# Port ที่แอปของคุณรัน (Default คือ 3000)
EXPOSE 3000

CMD [ "node", "dist/main" ]