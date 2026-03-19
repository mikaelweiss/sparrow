# Admin Dashboard

## Overview

Sparrow ships a built-in admin dashboard accessible at `/_admin`. It gives the developer full visibility into their running application — request metrics, active sessions, database performance, logs — without setting up Grafana, Datadog, or any external monitoring. Open a URL on your local network and see everything.

## Enabling

```swift
var config: some Config {
    Admin(.enabled)
    // or with custom path
    Admin(.enabled, path: "/_admin")
}
```

The admin dashboard is enabled by default in development mode and disabled by default in production. To enable in production:

```swift
Admin(.enabled, access: .authenticated(.admin))
```

## Access Control

The admin dashboard is **never** publicly accessible. Access modes:

| Mode | When to Use |
|---|---|
| `.localOnly` | Only accessible from localhost / 127.0.0.1 (default in dev) |
| `.network(allowlist:)` | Accessible from specific IPs or CIDR ranges (e.g., your Tailscale network) |
| `.authenticated(.admin)` | Accessible to authenticated users with the admin role |

```swift
// Local development — just open it on your Mac
Admin(.enabled, access: .localOnly)

// Accessible from your Tailscale network
Admin(.enabled, access: .network(allowlist: ["100.64.0.0/10"]))

// Production — admin users only
Admin(.enabled, access: .authenticated(.admin))
```

## Dashboard Sections

### Overview

The landing page shows at-a-glance health:

- **Server uptime** — how long since last restart
- **Active WebSocket sessions** — current connected users
- **Requests per minute** — HTTP + WebSocket events
- **Error rate** — percentage of 5xx responses in the last hour
- **Database status** — connected, pool utilization, average query time
- **Memory usage** — current RSS of the server process

### Requests

Live and historical request data:

- **Request log** — recent requests with method, path, status, latency, timestamp
- **Latency percentiles** — p50, p95, p99 over the last hour/day
- **Status code breakdown** — 2xx, 3xx, 4xx, 5xx distribution
- **Slowest endpoints** — top 10 endpoints by average latency
- **Error log** — recent 4xx and 5xx responses with details

Filterable by time range, path, status code.

### WebSocket Sessions

- **Active sessions** — list of current WebSocket connections with session ID, user (if authenticated), connected duration, current page
- **Session count over time** — graph of concurrent connections
- **Events per session** — average and outlier event rates
- **Reconnection rate** — how often clients are reconnecting (indicator of stability)

### Database

- **Query log** — recent queries with duration, table, operation type
- **Slow queries** — queries exceeding a configurable threshold (default: 100ms)
- **Connection pool** — active/idle/waiting connections
- **Table sizes** — row counts and storage size per table
- **Migration status** — applied and pending migrations

### Analytics

If analytics are enabled (see spec 20), the admin dashboard includes:

- **Page views** — total and per-page, with time range filtering
- **Unique visitors** — based on session/cookie, not IP
- **Top pages** — most visited pages
- **Referrers** — where traffic is coming from
- **Devices** — browser, OS, screen size breakdown
- **Geography** — country/region from IP (no external service, uses a bundled GeoIP database)

### Logs

Live log viewer with filtering:

- Stream server logs in real-time
- Filter by level (trace, debug, info, warning, error)
- Filter by source (http, websocket, database, auth, app)
- Search log messages

### System

- **Environment** — current environment (development/production), Swift version, Sparrow version
- **Configuration** — active database adapter, auth adapter, email adapter (values redacted)
- **Dependencies** — installed packages and versions

## Data Storage

The admin dashboard stores metrics in-memory with a configurable retention window. No additional database tables or external services required.

```swift
Admin(.enabled, retention: .hours(24))    // keep 24 hours of metrics (default)
Admin(.enabled, retention: .days(7))      // keep 7 days
```

Metrics are lost on server restart. For persistent monitoring in production, use the analytics system (spec 20) which writes to the database, or export to an external service.

### Export

The admin dashboard exposes a JSON API for metrics export:

```
GET /_admin/api/metrics          # current metrics snapshot
GET /_admin/api/requests         # request log
GET /_admin/api/sessions         # active sessions
GET /_admin/api/queries          # query log
```

These endpoints respect the same access control as the dashboard UI.

## UI

The admin dashboard is a Sparrow app itself — built with the same component system, design system, and rendering pipeline. It uses a dark theme variant and is completely self-contained (no external CSS or JS dependencies beyond the standard Sparrow runtime).

The dashboard auto-refreshes via the same WebSocket mechanism as any Sparrow page. Metrics update in real-time without polling.

## Alerts

Configurable alerts for common issues:

```swift
Admin(.enabled, alerts: [
    .errorRateAbove(5, percent: true, window: .minutes(5)),
    .slowQueries(threshold: .milliseconds(500)),
    .highMemory(threshold: .gigabytes(1)),
    .databasePoolExhausted,
])
```

Alerts appear as banners in the dashboard UI. Optionally, they can trigger email notifications (if an email adapter is configured):

```swift
Admin(.enabled, alertEmail: "ops@myapp.com")
```
