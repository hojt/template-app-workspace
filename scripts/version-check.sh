#!/usr/bin/env bash

set -euo pipefail

workspace_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
backend_dir="${workspace_root}/components/example-backend"
frontend_dir="${workspace_root}/components/example-frontend"

backend_version="$(cd "${backend_dir}" && ./mvnw --quiet -Dexpression=revision -DforceStdout help:evaluate)"
frontend_package_version="$(cd "${frontend_dir}" && node --input-type=module --eval "import packageJson from './package.json' with { type: 'json' }; console.log(packageJson.version)")"
frontend_lockfile_version="$(cd "${frontend_dir}" && node --input-type=module --eval "import packageLock from './package-lock.json' with { type: 'json' }; console.log(packageLock.version)")"
frontend_lockfile_package_version="$(cd "${frontend_dir}" && node --input-type=module --eval "import packageLock from './package-lock.json' with { type: 'json' }; console.log(packageLock.packages[''].version)")"

printf 'Backend revision: %s\n' "${backend_version}"
printf 'Frontend package version: %s\n' "${frontend_package_version}"
printf 'Frontend lockfile version: %s\n' "${frontend_lockfile_version}"
printf 'Frontend lockfile package version: %s\n' "${frontend_lockfile_package_version}"

if [[ -z "${backend_version}" ]] || [[ "${backend_version}" != "${frontend_package_version}" ]] || [[ "${backend_version}" != "${frontend_lockfile_version}" ]] || [[ "${backend_version}" != "${frontend_lockfile_package_version}" ]]; then
  echo "Workspace component versions do not match." >&2
  exit 1
fi

printf 'Workspace version: %s\n' "${backend_version}"
