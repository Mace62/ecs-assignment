# Stage 1: Build
FROM node:22-alpine@sha256:ab07539e0988b63558ff621f5fbe1077054c39d9809112974fb79993949d41cd AS builder

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install --frozen-lockfile

COPY . .

RUN yarn build

# Stage 2: Serve
FROM nginx:alpine@sha256:20316569d8f81a160065d7d2a5eeffc7ca97d79022462ee255fd23fa103a6b5c

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1/health | grep -q '"status":"ok"' || exit 1