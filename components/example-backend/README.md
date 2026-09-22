# example-backend

A minimal Quarkus backend start component for the application workspace template.

## Purpose

This component is versioned and developed with the workspace; it is not a
separate repository and the template application is not deployed.

It currently demonstrates:

- Quarkus
- Java 25
- Maven
- Podman
- Dev Containers
- Task-based automation
- OCI image build and publication
- application health endpoints
- external application configuration

The workspace is intentionally kept small and focused. This component serves as
a working example and a reference implementation for future backend services.

Platform infrastructure and environment-specific Kubernetes configuration are maintained separately.


## Requirements

Development is performed inside the provided Dev Container.

The developer host only needs the tooling required to start that environment, primarily:

- Podman
- Dev Container CLI

Workspace-specific development tooling is provided by the Dev Container.

## Development

Development is performed inside the provided Dev Container.

Start or reconnect to the workspace development environment from the workspace root with:

```bash
./dev.sh
```

This verifies the required host tooling, starts or reuses a repository-specific tmux session, starts the Dev Container, and opens a shell inside it.

Rebuild the development environment with:

```bash
./dev.sh rebuild
```

Once inside the Dev Container, start the application from the workspace root with:

```bash
task backend:dev
```

Or, from `components/example-backend`, use the component task:

```bash
task dev
```

The application is then available at:

```text
http://localhost:8080/api/greeting
```

Verify it with:

```bash
curl http://localhost:8080/api/greeting
```

By default, the greeting uses the application's configured default value.

### Agent-assisted development

An optional OpenCode-based environment is available for agent-assisted work.

Start or reconnect to it from the host with:

```bash
./agent.sh
```

This uses a separate agent Dev Container profile with reduced access to host resources and launches OpenCode inside a dedicated tmux session.

Rebuild the agent environment with:

```bash
./agent.sh rebuild
```

OpenCode authentication is user-specific and is kept outside the repository and container image.

## Configuration

The greeting is externally configurable through the Quarkus configuration property:

```text
greeting.message
```

Quarkus maps this to the environment variable:

```text
GREETING_MESSAGE
```

For example, the application can be started locally with:

```bash
GREETING_MESSAGE="Hello from config" task dev
```

Then:

```bash
curl http://localhost:8080/api/greeting
```

returns:

```json
{
  "message": "Hello from config"
}
```

On the platform, environment-specific values and deployment wiring are owned
outside this workspace. The required configuration names and defaults belong in
this component; the selected values do not.

## Health

The application exposes Quarkus health endpoints used by Kubernetes probes.

Liveness:

```text
/q/health/live
```

Readiness:

```text
/q/health/ready
```

When running locally, they can be inspected with:

```bash
curl http://localhost:8080/q/health/live
curl http://localhost:8080/q/health/ready
```

A healthy application returns a status of `UP`.

The platform deployment must configure liveness and readiness probes using these
paths; the probes themselves are environment configuration outside this
workspace.

## Tasks

From the workspace root, list the available workspace tasks with:

```bash
task --list
```

From `components/example-backend`, `task --list` lists the backend component tasks.
Task is the normal developer-facing interface for common operations such as development, testing, packaging, and container image handling.

## Container Image

The application is packaged and built into an OCI container image using Podman.

Image configuration, including the current image tag, is maintained by the
workspace scripts. The image tag is derived from the Maven revision and Git
information, so it is not independent of the Maven project version in `pom.xml`.

From the workspace root, build the image with `task backend:image:build` and publish it with `task backend:image:push`. From `components/example-backend`, use `task image:build` and `task image:push`.

The default registry address is `localhost:5001`, producing image references
such as `localhost:5001/example-backend:<tag>`. Override it with
`REGISTRY_HOST` and `REGISTRY_PORT`. The current scripts support only a
`host:port` registry address and disable TLS verification when pushing.

The exact available commands can always be inspected with:

```bash
task --list
```

## Platform Integration

The built backend image listens on port 8080. The platform must route `/api` to
it and configure the health endpoints above. The frontend's production browser
tracing posts to `/otel/v1/traces`; route that separately to an OTLP/HTTP trace
receiver rather than this backend. See the workspace README for the full
component contract.

## Project Structure

```text
.
├── scripts/
├── src/
├── Containerfile
├── Taskfile.yml
├── pom.xml
└── README.md
```

The repository follows a simple automation layering:

```text
Task
  │
  ▼
scripts/
  │
  ▼
Maven / Podman
```

Task provides the stable developer-facing interface while reusable or non-trivial operations live in shell scripts under `scripts/`.

This keeps the underlying commands visible and makes the same automation reusable from future CI/CD pipelines.

## Component Responsibilities

This component owns:

- application source code
- application tests
- application packaging
- container image construction
- container image publication
- application-level health capabilities
- application configuration properties and defaults

It does not own:

- Kubernetes platform infrastructure
- Kubernetes Deployment configuration
- environment-specific configuration values
- Gateway configuration
- workload routing
- certificate management

Those responsibilities belong to the platform and environment configuration,
outside this workspace.

## Status

The current backend reference implementation includes:

- Dev Container development environment
- Quarkus application
- automated tests
- Maven package build
- OCI container image build
- configurable application greeting
- liveness health endpoint
- readiness health endpoint
- isolated OpenCode agent development environment

The component remains intentionally small. Additional capabilities should be
introduced only for a concrete application requirement.
