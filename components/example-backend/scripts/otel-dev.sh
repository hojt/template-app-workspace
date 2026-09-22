#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"

config_file="${repo_root}/util/otel-collector.yaml"

export OTELCOL_CONFIG
OTELCOL_CONFIG="$(<"${config_file}")"

podman run --rm \
  --name example-backend-otel-collector \
  --publish 4317:4317 \
  --publish 4318:4318 \
  --env OTELCOL_CONFIG \
  otel/opentelemetry-collector:0.158.0 \
  --config=env:OTELCOL_CONFIG
