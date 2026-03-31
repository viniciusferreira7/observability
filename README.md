> [!WARNING]
> **WIP** — This project is a work in progress.

# Observability

A study project focused on learning and implementing observability concepts in modern applications using the **Grafana LGTM stack**.

## Stack

| Tool | Version | Purpose | Port |
|------|---------|---------|------|
| **Loki** | 3.7.1 | Log aggregation | 3100 |
| **Grafana Tempo** | 2.6.1 | Distributed tracing | 3200 (HTTP), 4317 (gRPC), 4318 (OTLP HTTP) |
| **Grafana Mimir** | 3.0.5 | Metrics storage | 9090 |
| **Promtail** | 3.6 | Log collection agent | — |
| **Grafana** | 12.4.2 | Visualization & dashboards | 3000 |

## Goals

- Understand logs, metrics, and tracing (the three pillars of observability)
- Gain hands-on experience monitoring distributed systems
- Explore how to correlate signals across the LGTM stack in practice

## Running

```bash
docker compose up -d
```

Grafana will be available at [http://localhost:3000](http://localhost:3000).

## Configuration

Copy `.env.example` to `.env` and set the required variables:

| Variable | Description |
|----------|-------------|
| `GF_SECURITY_ADMIN_USER` | Grafana admin username |
| `GF_SECURITY_ADMIN_PASSWORD` | Grafana admin password |
| `GF_AUTH_ANONYMOUS_ENABLED` | Enable anonymous access (`true`/`false`) |
| `GF_AUTH_ANONYMOUS_ORG_ROLE` | Role for anonymous users (`Viewer`, `Editor`, `Admin`) |
| `GF_SECURITY_ALLOW_EMBEDDING` | Allow Grafana to be embedded in iframes (`true`/`false`) |
