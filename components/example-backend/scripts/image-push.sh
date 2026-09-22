#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"

source "${script_dir}/config.sh"
source "${script_dir}/version.sh"

cd "${repo_root}"

require_clean_git_worktree

app_version="$(get_app_version "${repo_root}")"

local_image="localhost/${IMAGE_NAME}:${app_version}"
registry_image="${REGISTRY_ADDRESS}/${IMAGE_NAME}:${app_version}"

if ! podman image exists "${local_image}"; then
  echo "Local image does not exist: ${local_image}" >&2
  echo "Build it first with: task image:build" >&2
  exit 1
fi

echo "Tagging ${local_image} as ${registry_image}"

podman tag \
  "${local_image}" \
  "${registry_image}"

echo "Pushing ${registry_image}"

podman push \
  --tls-verify=false \
  "${registry_image}"

echo "Published ${registry_image}"
