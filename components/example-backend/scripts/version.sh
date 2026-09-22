#!/usr/bin/env bash

get_git_sha() {
  git rev-parse --short=8 HEAD
}

is_git_dirty() {
  [[ -n "$(git status --porcelain)" ]]
}

get_version_suffix() {
  local git_sha
  local suffix

  git_sha="$(get_git_sha)"
  suffix="-${git_sha}"

  if is_git_dirty; then
    suffix="${suffix}-dirty"
  fi

  printf '%s\n' "${suffix}"
}

get_release_version() {
  local repo_root="$1"

  "${repo_root}/mvnw" \
    --quiet \
    -Dsha1= \
    help:evaluate \
    -Dexpression=project.version \
    -DforceStdout
}

get_app_version() {
  local repo_root="$1"
  local version_suffix

  version_suffix="$(get_version_suffix)"

  "${repo_root}/mvnw" \
    --quiet \
    -Dsha1="${version_suffix}" \
    help:evaluate \
    -Dexpression=project.version \
    -DforceStdout
}

require_release_tag() {
  local release_version="$1"
  local expected_tag="${release_version}"

  if ! git tag --points-at HEAD | grep --fixed-strings --line-regexp --quiet "${expected_tag}"; then
    echo "HEAD is not tagged ${expected_tag}." >&2
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
