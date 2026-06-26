# Stage 1: Build
FROM node:22-alpine@sha256:b74031e546d7f4faf561d797ac1b76beccac856a042815ca77db4fd047581605 AS builder

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install --frozen-lockfile

COPY . .

RUN yarn build

# Stage 2: Serve
FROM nginx:alpine@sha256:35cd77497979abe70dc8d26f5ae60811eea233a2eb5dc03c2ee30972caeb303e

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /app/build /usr/share/nginx/html

RUN chown -R nginx:nginx /usr/share/nginx/html \
    /var/cache/nginx /var/log/nginx /etc/nginx/conf.d \
 && touch /var/run/nginx.pid \
 && chown nginx:nginx /var/run/nginx.pid

USER nginx

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1/health | grep -q '"status":"ok"' || exit 1