# Changelog

## 0.165.0 (2026-11-16)

- First release: OpenTelemetry Collector contrib `0.165.0` (`sha256:e40d61f10c9a617cca1ffd1be4d7e2b3a4b0f0001798ff07e58cabe82e618cea`).
- OTLP/HTTP on the public domain (4318) and OTLP/gRPC on the private network (4317), both behind bearer-token auth.
- Health check on `PORT` (13133), `debug` exporter by default, optional `otlphttp/upstream` exporter with a persistent queue on the volume at `/var/lib/otelcol`.
