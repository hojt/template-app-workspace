#!/usr/bin/env bash

get_git_sha() {
  git rev-parse --short=8 HEAD
}

is_git_dirty() {
  [[ -n "$(git status --porcelain)" ]]
}

get_version_suffix() {
  local suffix

  suffix="-$(get_git_sha)"

  if is_git_dirty; then
    suffix="${suffix}-dirty"
  fi

  printf '%s\n' "${suffix}"
}

get_release_version() {
  local component_root="$1"

  node --input-type=module --eval \
    "import packageJson from '${component_root}/package.json' with { type: 'json' }; console.log(packageJson.version)"
}

get_app_version() {
  local component_root="$1"

  printf '%s%s\n' "$(get_release_version "${component_root}")" "$(get_version_suffix)"
}

require_release_tag() {
  local release_version="$1"

  if ! git tag --points-at HEAD | grep --fixed-strings --line-regexp --quiet "${release_version}"; then
    echo "HEAD is not tagged ${release_version}." >&2
    return 1
  fi
}

require_clean_git_worktree() {
  if is_git_dirty; then
    echo "Git working tree is dirty." >&2
    echo "Commit or stash changes before publishing an image." >&2
    return 1
  fi
}
