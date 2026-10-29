#!/usr/bin/env bash
# Merges a released version of template-app-workspace into this workspace.
# Owned by the template. See ADR-0014 in hojt/homelab.
set -euo pipefail

if [[ "$(git remote get-url origin 2>/dev/null)" == *"/template-app-workspace"* ]]; then
  echo "This is the template itself; run template:update in an application." >&2
  exit 2
fi

if (($# != 1)); then
  echo "usage: task template:update -- <version>" >&2
  exit 2
fi
version="$1"

remote="${TEMPLATE_REMOTE:-https://github.com/hojt/template-app-workspace.git}"
ref="refs/template/${version}"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Commit or stash local changes before updating the template." >&2
  exit 1
fi

# Fetch the template version outside the application's own tags.
git fetch --no-tags "${remote}" "+refs/tags/${version}:${ref}"

if git merge --no-ff --no-commit "${ref}"; then
  :
fi

# Keep content the application has removed, such as the example components.
git status --porcelain | awk '/^DU /{print $2}' | xargs -r git rm --quiet

if [[ -n "$(git diff --name-only --diff-filter=U)" ]]; then
  echo
  echo "Resolve the remaining conflicts, then commit with:" >&2
  echo "  git commit -m \"chore(template): update to ${version}\"" >&2
  exit 1
fi

git commit --quiet -m "chore(template): update to ${version}"
echo "Merged template ${version}. Review it with: git show --stat HEAD"
