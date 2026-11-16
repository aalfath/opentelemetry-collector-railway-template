# OpenTelemetry Collector (contrib distribution) for Railway.
# Upstream: https://github.com/open-telemetry/opentelemetry-collector-releases
FROM otel/opentelemetry-collector-contrib:0.165.0@sha256:e40d61f10c9a617cca1ffd1be4d7e2b3a4b0f0001798ff07e58cabe82e618cea

COPY config.yaml /etc/otelcol-contrib/railway.yaml

# Railway volumes are mounted owned by root, and the persistent export queue
# lives on the volume at /var/lib/otelcol, so the collector runs as root.
USER 0:0

# 4318 = OTLP/HTTP (public domain), 4317 = OTLP/gRPC (private network),
# 13133 = health check (Railway's PORT).
EXPOSE 4317 4318 13133

ENTRYPOINT ["/otelcol-contrib"]
CMD ["--config=/etc/otelcol-contrib/railway.yaml"]
