#!/bin/sh
# Runs the GitHub CLI with the installation token issued on the host.
# The token is read on each call and is exported only to this gh process,
# never to the environment of the agent container. See ADR-0013.
set -eu
GH_TOKEN="$(cat /run/agent-github/token)"
export GH_TOKEN
exec /usr/bin/gh "$@"
