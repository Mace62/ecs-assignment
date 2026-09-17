# Stage 1: Build frontend
FROM node:22-alpine@sha256:b74031e546d7f4faf561d797ac1b76beccac856a042815ca77db4fd047581605 AS builder

WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build

# Stage 2: Compile Go server with embedded static assets
FROM golang:1.26-alpine@sha256:ce864e7223ac17b1775e6fd0b4c0db580c2eb50e7953a427916379e4b92a1628 AS server

WORKDIR /src
COPY server/go.mod ./
COPY server/main.go ./
COPY --from=builder /app/build ./static

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -trimpath -o /server .

# Stage 3: Distroless runtime (non-root UID 65532, no shell, no apk)
FROM gcr.io/distroless/static-debian12@sha256:d093aa3e30dbadd3efe1310db061a14da60299baff8450a17fe0ccc514a16639

COPY --from=server /server /server

ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/server"]