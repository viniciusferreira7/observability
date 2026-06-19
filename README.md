# Observability

A study project focused on learning and implementing observability concepts in modern applications using the **Grafana LGTM stack**, fed through an **OpenTelemetry Collector** and backed by **Garage** for S3-compatible object storage.

This stack is used by [fast-feet-api](https://github.com/viniciusferreira7/fast-feet-api) as its observability backend.

## Stack

| Tool | Version | Purpose | Host Port |
|------|---------|---------|-----------|
| **OpenTelemetry Collector** | `contrib:nightly` | Receives OTLP and fans signals out to the backends | 4317 (gRPC), 4318 (HTTP), 8888/8889 (metrics), 13133 (health), 55679 (zpages), 1888 (pprof) |
| **Loki** | 3.7.1 | Log aggregation | 3100 |
| **Grafana Tempo** | 2.6.1 | Distributed tracing | — (internal: 3200 HTTP, 4317 gRPC, 4318 OTLP HTTP) |
| **Grafana Mimir** | 3.0.5 | Long-term metrics storage | 9008, 9009 |
| **Prometheus** | `main-distroless` | Metrics (remote-write receiver enabled) | 9090 |
| **Promtail** | 3.6 | Log collection agent (`/var/log`) | — |
| **Garage** | 2.1.0 | S3-compatible object storage for Loki/Tempo/Mimir | 3900 (S3 API), 3903 (Admin API) |
| **Garage Web UI** | 1.1.0 | Buckets, keys & layout via the Admin API | 3909 |
| **Grafana** | 12.4.2 | Visualization & dashboards | 3000 |

## Goals

- Understand logs, metrics, and tracing (the three pillars of observability)
- Gain hands-on experience monitoring distributed systems
- Explore how to correlate signals across the LGTM stack in practice

## Architecture

Applications send OTLP telemetry to the **OpenTelemetry Collector** (`localhost:4317` gRPC / `localhost:4318` HTTP), which routes each signal to its backend:

- **Logs** → Loki (`/otlp`)
- **Traces** → Tempo (OTLP gRPC)
- **Metrics** → Mimir (remote-write) and exposed locally for Prometheus to scrape

Loki, Tempo, and Mimir persist their data in **Garage** buckets (`loki-data`, `loki-ruler`, `tempo`, `mimir`), which are created at startup by the one-shot `garage-init` service. **Grafana** is provisioned with Loki, Tempo, Mimir, and Prometheus datasources out of the box.

## Running

```bash
docker compose up -d
```

On first start, `garage-init` assigns the cluster layout, imports the S3 key, and creates the required buckets before Loki, Tempo, and Mimir come up.

- Grafana: [http://localhost:3000](http://localhost:3000)
- Garage Web UI: [http://localhost:3909](http://localhost:3909)

## Configuration

Copy `.env.example` to `.env` and set the required variables:

### Garage (S3-compatible object storage)

| Variable | Description | How to generate |
|----------|-------------|-----------------|
| `GARAGE_RPC_SECRET` | Cluster RPC secret | `openssl rand -hex 32` |
| `GARAGE_ADMIN_TOKEN` | Admin API token | `openssl rand -base64 32` |
| `GARAGE_ACCESS_KEY` | S3 access key (`GK` + 24 hex chars) | `echo GK$(openssl rand -hex 12)` |
| `GARAGE_SECRET_KEY` | S3 secret key (64 hex chars) | `openssl rand -hex 32` |

### Grafana

| Variable | Description |
|----------|-------------|
| `GF_SECURITY_ADMIN_USER` | Grafana admin username |
| `GF_SECURITY_ADMIN_PASSWORD` | Grafana admin password |
| `GF_AUTH_ANONYMOUS_ENABLED` | Enable anonymous access (`true`/`false`) |
| `GF_AUTH_ANONYMOUS_ORG_ROLE` | Role for anonymous users (`Viewer`, `Editor`, `Admin`) |
| `GF_SECURITY_ALLOW_EMBEDDING` | Allow Grafana to be embedded in iframes (`true`/`false`) |
