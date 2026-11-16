# OpenTelemetry Collector on Railway

Railway template for the [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/) (contrib distribution), a vendor-neutral gateway that receives traces, metrics and logs over OTLP, batches them and forwards them to any backend.

- **Version:** `otel/opentelemetry-collector-contrib:0.165.0`, pinned by digest in the [`Dockerfile`](Dockerfile).
- **Config:** [`config.yaml`](config.yaml). Every setting you are likely to change is a service variable, so you don't need to fork the repo.

## What the template deploys

One service, built from this repo:

| Port | What | Reachable from |
|---|---|---|
| 4318 | OTLP/HTTP receiver | Public Railway domain (`https://YOUR-DOMAIN/v1/traces`, `/v1/metrics`, `/v1/logs`) and the private network |
| 4317 | OTLP/gRPC receiver | Private network only (`otel-collector.railway.internal:4317`) |
| 13133 | Health check (`PORT`) | Railway's deploy health check |

Both receivers require `Authorization: Bearer <OTEL_AUTH_TOKEN>`. Requests without it get `401` (HTTP) or `Unauthenticated` (gRPC).

A volume at `/var/lib/otelcol` holds the persistent export queue: when the upstream backend is unreachable, telemetry waits on disk and is delivered after a restart or redeploy.

## Variables

| Variable | Default | Purpose |
|---|---|---|
| `OTEL_AUTH_TOKEN` | generated secret | Bearer token every OTLP client must send |
| `PORT` | `13133` | Health check port probed by Railway |
| `OTEL_EXPORTERS` | `[debug]` | Exporters for every pipeline. Set to `[debug, otlphttp/upstream]` or `[otlphttp/upstream]` to forward |
| `OTLP_UPSTREAM_ENDPOINT` | unset | Base URL of an OTLP/HTTP backend, e.g. `https://otlp-gateway-prod-eu-west-2.grafana.net/otlp` |
| `OTLP_UPSTREAM_HEADERS` | `[]` | Headers for the backend as a JSON map, e.g. `{"Authorization":"Basic abc123"}` or `{"x-honeycomb-team":"KEY"}` |
| `OTEL_DEBUG_VERBOSITY` | `basic` | `basic`, `normal` or `detailed` output of the `debug` exporter in the deploy logs |
| `OTEL_MEMORY_LIMIT_MIB` | `1024` | Memory limiter ceiling; raise it for heavy traffic |

## Sending data

Point any OpenTelemetry SDK at the collector:

```sh
OTEL_EXPORTER_OTLP_ENDPOINT=https://YOUR-DOMAIN
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
OTEL_EXPORTER_OTLP_HEADERS=Authorization=Bearer%20YOUR-TOKEN
```

From another service in the same Railway project, use `http://${{otel-collector.RAILWAY_PRIVATE_DOMAIN}}:4318` (HTTP) or port `4317` (gRPC), with the token from `${{otel-collector.OTEL_AUTH_TOKEN}}` (the service is called `otel-collector`).

## Updates

This template builds from this repo's `main` branch. When a new collector release is merged here (bumped pin plus a [`CHANGELOG.md`](CHANGELOG.md) entry), Railway shows deployers an "update available" notice, and they choose when to apply it. Read the changelog first: collector releases can rename or remove components.
