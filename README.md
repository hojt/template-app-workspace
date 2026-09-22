# template-app-workspace

Starter workspace for a self-contained application on the platform. It includes
a Quarkus/Java/Maven backend and a Vite/React/TypeScript frontend as working
examples. Copy it into a new Git repository, then follow
[`docs/create-application.md`](docs/create-application.md) to give that
application its own identity. The checked-in `example-*` components are working
starting points, not a deployed application.

## Structure

```text
components/
  example-backend/   # Quarkus, Java, and Maven reference backend
  example-frontend/ # Vite, React, and TypeScript reference frontend
docs/                # template and application documentation
```

Components are ordinary directories versioned with the workspace. They are
independently buildable and deployable, while the workspace supplies common
tasks and a shared application version. The pattern is not tied to the example
frameworks: a frontend based on another Node.js/npm stack can replace
`example-frontend` while retaining this component structure. The backend example
uses Java and Maven; another Java/Maven backend can likewise replace Quarkus.
Any replacement backend must provide equivalent build, verification, image, and
version integration.

## New Checkout Or File Copy

For a Git checkout, use its existing `.git` directory. For a file copy, do not
copy the template's `.git`, `node_modules`, or build results. From the new
repository root, initialize Git before starting the agent environment:

```bash
git init
./agent.sh
```

Normal verification commands do not require commits. Review and stage the new
application, then create its first commit before running image builds: image
tags require a resolvable Git `HEAD`. The user, not the agent, creates that
commit.

The host needs Podman, the Dev Container CLI, and tmux. Start the developer
container from the workspace root:

```bash
./dev.sh
```

Inside that container, install the checked-in frontend example's locked npm
dependencies before using its frontend tasks:

```bash
cd components/example-frontend
npm ci
cd ../..
```

Run the development servers in separate shells in the same developer container:

```bash
# first shell
task backend:dev

# second shell, opened from the host workspace root
./dev.sh shell
task frontend:dev
```

Then use the root task interface for the remaining commands:

```bash
task --list
task version:check
task backend:verify
task frontend:verify
```

The checked-in backend example's `http://localhost:8080` addresses apply inside
the developer container. The browser uses the checked-in Vite frontend example,
published from the developer container only on host loopback. Vite remains on
container port 5173; by default the browser URL is `http://127.0.0.1:5173`.
Select another host port at container creation time, for example:

```bash
FRONTEND_HOST_PORT=5174 ./dev.sh rebuild
```

`FRONTEND_HOST_PORT` changes only the published host port; the checked-in Vite
example still listens on 5173 in the container. A replacement frontend must
update this publication and its development-server port as needed. A changed
value requires recreating the developer container from the host, so use
`./dev.sh rebuild`. A normal `./dev.sh` start reconnects to the existing tmux
session and keeps its port choice. The agent container publishes no ports.

`./agent.sh` starts the separate, access-restricted coding-agent environment.
Its restrictions are intentional and are not a substitute for the developer
environment or host browser testing.

## Versions And Images

All components share one declared version. Set and check it from the workspace
root:

```bash
task version:set VERSION=0.0.1
task version:check
```

`version:check`, application builds, and tests do not require Git history.
Image builds do: their development tags include `git rev-parse HEAD` and dirty
state. `task backend:image:build` and `task frontend:image:build` therefore
require a checkout with a resolvable Git `HEAD`. Image push/release tasks also
require a clean worktree; release tasks require the matching version tag on
`HEAD`.

The existing registry scripts remain available. Their registry configuration is
`REGISTRY_HOST` plus `REGISTRY_PORT` and only supports a `host:port` address.
Their push operation deliberately uses `--tls-verify=false`; do not treat that
as production registry configuration.

## Platform Integration

Development runs the checked-in Vite and Quarkus examples directly in the
developer container. Platform execution instead runs the built images and is
configured by platform and environment repositories; this workspace does not
own deployment manifests.

The current example component contract is:

- The frontend image serves HTTP on port 8080 and the backend serves HTTP on port 8080.
- Route `/api` to the backend, including `/api/greeting`.
- Route `/otel/v1/traces` to an OTLP/HTTP trace receiver. The production frontend exports browser traces to that relative path.
- Configure backend liveness and readiness probes as `/q/health/live` and `/q/health/ready`.
- Supply environment-specific Quarkus configuration externally, for example `GREETING_MESSAGE` for `greeting.message` and `GREETING_SECRET` for `greeting.secret`. Keep values and deployment wiring outside this workspace.

Start the optional local collector from the developer container with:

```bash
cd /workspace/components/example-backend
task otel:dev
```

It has the fixed container name `example-backend-otel-collector` and publishes
host ports 4317 and 4318; adapt its name and ports before running multiple
instances.
