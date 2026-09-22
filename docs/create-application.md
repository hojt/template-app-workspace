# Create An Application

Use this checklist after copying `template-app-workspace` into a new Git
repository. Keep the working `example-*` components until every relevant
reference has been changed and verified. This template has no generator,
automatic rename command, or submodule implementation.

## Repository Preconditions

- A Git checkout keeps its existing `.git` directory. A file copy must not copy the template's `.git`, `node_modules`, or build results.
- For a file copy, run `git init` from the new repository root before running `./agent.sh`.
- Normal verification commands can run without commits. Review and stage the application, then make the first commit before image builds that require `HEAD`.
- The user reviews, stages, and creates the first commit. The agent must not create it.

## Identity And Development Environment

- Rename the workspace directory and Git repository to the application name.
- Change the developer and agent devcontainer `name` values in `.devcontainer/devcontainer.json` and `.devcontainer/agent/devcontainer.json`.
- Rename every workspace-specific development volume, including Maven, npm, and Neovim data volumes. Give any new database or service data volumes application-specific names too.
- Update workspace-facing messages and documentation, including `agent.sh` containment verification.
- Select a host frontend port with `FRONTEND_HOST_PORT=<port> ./dev.sh rebuild`. Keep Vite's internal port 5173 and its `0.0.0.0` binding. Keep the agent devcontainer free of published ports.

## Components And Metadata

- Rename `components/example-backend` and `components/example-frontend` to the new component names.
- Update root task directories and both version scripts to the renamed component paths. Preserve the existing task names unless a deliberate interface change is required.
- Change the Maven `groupId`, `artifactId`, Java package, resource paths, and affected backend tests.
- Change the npm `name`, frontend display text, telemetry service name, and affected frontend tests.
- Run `npm install --package-lock-only` or `npm version --no-git-tag-version` as appropriate so `package-lock.json` has the same package name and version as `package.json`; use `npm ci` to install the lockfile afterwards.
- Change `IMAGE_NAME` defaults and any Containerfile labels or image references for both components.
- Set the initial common release version with `task version:set VERSION=0.1.0`, then run `task version:check`.

## Platform Contract

- Keep or deliberately change and document the frontend and backend image ports, currently both 8080.
- Route `/api` to the backend and `/otel/v1/traces` to an OTLP/HTTP trace receiver.
- Keep Quarkus liveness and readiness paths `/q/health/live` and `/q/health/ready`, or update platform probes and documentation together.
- Define configuration property names and defaults in the backend, then configure environment-specific values externally. Do not put deployment manifests or environment values in this workspace.
- Choose registry host and port through `REGISTRY_HOST` and `REGISTRY_PORT`. Current image scripts require a `host:port` address and push with TLS verification disabled; replace that behavior before using a registry that needs a different security model.
- If using the local collector alongside another application, change its fixed collector name and published ports 4317/4318 first. Start it from the developer container with `cd /workspace/components/example-backend && task otel:dev`.

## Before First Release

- Install frontend dependencies with `npm ci` inside any `components/<frontend>`.
- Run `task version:check`, `task backend:verify`, and `task frontend:verify`.
- Build both images without publishing: `task backend:image:build` and `task frontend:image:build`.
- Image builds require a resolvable Git `HEAD`. Development image tags use the current commit; release scripts additionally require a clean worktree and an exact version tag on `HEAD`.
