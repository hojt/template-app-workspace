# Create An Application

Use this checklist after copying `template-app-workspace` into a new Git
repository. Keep the working `example-*` components until every relevant
reference has been changed and verified. This template has no generator,
automatic rename command, or submodule implementation.

The checked-in examples are a Quarkus/Java/Maven backend and a
Vite/React/TypeScript frontend. The workspace pattern is component-oriented,
not framework-oriented: another Node.js/npm frontend stack can replace the
frontend example, and another Java/Maven backend can replace Quarkus. A
replacement backend must provide corresponding build, verification, image, and
version integration.

## Repository Preconditions

- A Git checkout keeps its existing `.git` directory. A file copy must not copy the template's `.git`, `node_modules`, or build results.
- Rename the workspace directory to the application name before the first agent session. Agent state, including the agent's clone, its delivery repository, and its OpenCode login, is tied to the directory name.
- For a file copy, run `git init` from the new repository root, then commit the copied template as the starting point: `git add .` and `git commit -m "chore: start from template-app-workspace"`. The agent clones committed history only, so `./agent.sh` cannot start before the repository has a commit.
- Each workspace keeps its own agent state. Before the first agent session, log in to OpenCode from an agent shell: `./agent.sh shell`, then `opencode auth login`. Claude Code reuses the shared token in `~/.config/claude-agent/oauth-token`.
- The user reviews, stages, and creates commits in this repository. The agent works in its own clone and delivers branches named `agent/<topic>`, which the user fetches with `./agent.sh fetch`, reviews, and merges. See the README for the workflow.
- Normal verification commands do not require further commits. Image builds require a resolvable Git `HEAD`.

The remaining steps can be done by hand or delegated to the agent. Agent work
arrives as branches, so each step can be reviewed before it is merged.

## Identity And Development Environment

- Rename the Git repository to the application name, matching the workspace directory.
- Container, volume, network, and proxy names derive from the workspace directory name, so renaming the directory renames them. Give any new volume a name based on `${localWorkspaceFolderBasename}` in the same way.
- Update workspace-facing messages and documentation. `agent.sh` is shared across workspaces and needs no changes; its workspace-specific layout lives in `.devcontainer/agent/sandbox.conf`.
- Select a host frontend port with `FRONTEND_HOST_PORT=<port> ./dev.sh rebuild`. Keep Vite's internal port 5173 and its `0.0.0.0` binding. Keep the agent devcontainer free of published ports.

## Components And Metadata

- Rename `components/example-backend` and `components/example-frontend` to the new component names. The agent works in its own clone, so renaming components needs no sandbox changes.
- Update root task directories and both version scripts to the renamed component paths. Preserve the existing task names unless a deliberate interface change is required.
- For the supplied Java/Maven backend, change the Maven `groupId`, `artifactId`, Java package, resource paths, and affected backend tests. If replacing it, provide equivalent component tasks and version integration for the selected backend stack.
- The supplied frontend can be replaced by another Node.js/npm stack. Update its package name, display text, telemetry service name, tests, component tasks, Containerfile, and development-server configuration for that stack.
- For an npm frontend, run `npm install --package-lock-only` or `npm version --no-git-tag-version` as appropriate so `package-lock.json` has the same package name and version as `package.json`; use `npm ci` to install the lockfile afterwards.
- Change `IMAGE_NAME` defaults and any Containerfile labels or image references for both components.
- Set the initial common release version with `task version:set VERSION=0.0.1`, then run `task version:check`.

## Platform Contract

- Keep or deliberately change and document the example frontend and backend image ports, currently both 8080.
- Keep or deliberately change the example routes `/api` and `/otel/v1/traces`, then update platform configuration and documentation together.
- Keep the Quarkus example's liveness and readiness paths `/q/health/live` and `/q/health/ready`, or update platform probes and documentation together.
- Define configuration property names and defaults in the backend, then configure environment-specific values externally. Do not put deployment manifests or environment values in this workspace.
- Choose registry host and port through `REGISTRY_HOST` and `REGISTRY_PORT`. Current image scripts require a `host:port` address and push with TLS verification disabled; replace that behavior before using a registry that needs a different security model.
- If using the local collector alongside another application, change its fixed collector name and published ports 4317/4318 first. Start it from the workspace root in the developer container with `cd components/example-backend && task otel:dev`.

## Before First Release

- Install frontend dependencies with `npm ci` inside any `components/<frontend>`.
- Run `task version:check`, `task backend:verify`, and `task frontend:verify`.
- Build both images without publishing: `task backend:image:build` and `task frontend:image:build`.
- Image builds require a resolvable Git `HEAD`. Development image tags use the current commit; release scripts additionally require a clean worktree and an exact version tag on `HEAD`.
