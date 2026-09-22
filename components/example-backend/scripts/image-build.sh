#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"

source "${script_dir}/config.sh"
source "${script_dir}/version.sh"

cd "${repo_root}"

version_suffix="$(get_version_suffix)"
app_version="$(get_app_version "${repo_root}")"
local_image="localhost/${IMAGE_NAME}:${app_version}"

echo "Running Maven package"
echo "Application version: ${app_version}"

./mvnw \
  -Dsha1="${version_suffix}" \
  package

echo
echo "Building image ${local_image}"

podman build \
  --tag "${local_image}" \
  --file Containerfile \
  .
