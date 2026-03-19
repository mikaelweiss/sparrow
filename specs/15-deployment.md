# Deployment

## Overview

`sparrow build` produces a self-contained server binary and static assets. Deploy anywhere you can run a Linux binary. No Node.js, no npm, no runtime dependencies.

## Build Output

```
$ sparrow build

Output:
  .build/release/MyApp              # compiled server binary (Linux x86_64)
  .build/release/public/
    sparrow.css                      # generated stylesheet
    sparrow-runtime.js               # client JS runtime
    assets/                          # copied from Assets/
      logo.png
      favicon.ico
```

The binary is statically linked. It includes the Hummingbird server, all your views, the renderer, and the data layer. No external Swift runtime needed.

## Running in Production

```
DATABASE_URL=postgres://... ./MyApp
```

The binary starts the HTTP server, connects to Postgres, and serves your app. That's it.

### Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `DATABASE_URL` | Yes | — | Postgres connection string |
| `PORT` | No | `5456` | HTTP server port |
| `HOST` | No | `0.0.0.0` | Bind address |
| `SPARROW_ENV` | No | `production` | Environment (`development` or `production`) |
| `SPARROW_SECRET` | Yes (prod) | auto-generated (dev) | Secret key for session signing |

In production mode (`SPARROW_ENV=production`):
- Secure cookies are enforced (HTTPS required)
- Debug error overlays are disabled
- Build error WebSocket messages are disabled
- Detailed error messages are hidden from users

## Docker

```
$ sparrow build --docker
```

Generates a `Dockerfile`:

```dockerfile
# Build stage
FROM swift:6.2 AS builder
WORKDIR /app
COPY . .
RUN sparrow build

# Runtime stage
FROM swift:6.2-slim
WORKDIR /app
COPY --from=builder /app/.build/release/MyApp .
COPY --from=builder /app/.build/release/public ./public
EXPOSE 5456
CMD ["./MyApp"]
```

Build and run:

```
$ sparrow build --docker --run

  ✓ Built Docker image: myapp:latest
  ✓ Running on http://localhost:5456
```

## Platform Deployment

### Fly.io

```
$ sparrow deploy --fly

  Generating fly.toml...
  ✓ Created Postgres database
  ✓ Deployed to https://myapp.fly.dev
```

### Railway

```
$ sparrow deploy --railway
```

### Render

```
$ sparrow deploy --render
```

### Manual / VPS

1. Build the binary locally (or in CI) for Linux:
   ```
   sparrow build --platform linux
   ```
2. Copy the binary and `public/` directory to your server
3. Set environment variables
4. Run the binary behind a reverse proxy (nginx, Caddy)

### Caddy Example

```
myapp.com {
    reverse_proxy localhost:5456
}
```

Caddy auto-provisions HTTPS via Let's Encrypt.

## Health Check

Sparrow exposes a health check endpoint at `GET /health`:

```json
{"status": "ok", "uptime": 3600, "database": "connected"}
```

Use this for load balancer health checks, Docker health checks, and monitoring.

## Static Assets & CDN

The `public/` directory contains all static assets. In production, you can serve these from a CDN:

```toml
# Sparrow.toml
[production]
assetHost = "https://cdn.myapp.com"
```

When set, all asset URLs in the generated HTML point to the CDN instead of the server.

## Database Migrations in Production

Migrations run automatically on server start in development mode. In production, run them explicitly before deploying:

```
sparrow migrate --apply
```

Or in your deployment script:

```
./MyApp --migrate    # run migrations and exit
./MyApp              # start the server
```

## Logging

Sparrow uses Swift's `swift-log` for structured logging:

```
[2026-03-19 14:30:00] INFO  Server started on :5456
[2026-03-19 14:30:01] INFO  Database connected (pool: 20)
[2026-03-19 14:30:05] INFO  GET /  200 12ms
[2026-03-19 14:30:06] INFO  WS connected session=abc123
[2026-03-19 14:30:10] INFO  WS event session=abc123 type=click target=v_0_2
```

Log level is configurable:

```toml
[production]
logLevel = "info"    # trace, debug, info, warning, error
```
