#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
component_root="$(cd -- "${script_dir}/.." && pwd)"

source "${script_dir}/config.sh"
source "${script_dir}/version.sh"

cd "${component_root}"

app_version="$(get_app_version "${component_root}")"
local_image="localhost/${IMAGE_NAME}:${app_version}"

echo "Building frontend artifact"
npm run build

echo
echo "Building image ${local_image}"
podman build \
  --tag "${local_image}" \
  --file Containerfile \
  .
