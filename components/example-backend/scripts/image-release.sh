#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"

source "${script_dir}/config.sh"
source "${script_dir}/version.sh"

cd "${repo_root}"

require_clean_git_worktree

release_version="$(get_release_version "${repo_root}")"
require_release_tag "${release_version}"

local_image="localhost/${IMAGE_NAME}:${release_version}"
registry_image="${REGISTRY_ADDRESS}/${IMAGE_NAME}:${release_version}"

echo "Building release ${release_version}"

./mvnw \
  -Dsha1= \
  package

echo
echo "Building release image ${local_image}"

podman build \
  --tag "${local_image}" \
  --file Containerfile \
  .

echo
echo "Tagging ${local_image} as ${registry_image}"

podman tag \
  "${local_image}" \
  "${registry_image}"

echo "Pushing ${registry_image}"

podman push \
  --tls-verify=false \
  "${registry_image}"

echo
echo "Published release ${registry_image}"
