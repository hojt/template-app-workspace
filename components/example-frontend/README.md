# example-frontend

Working Vite, React, and TypeScript start component for the application
workspace template.

## Development

From the workspace root, use the workspace tasks:

```bash
task frontend:dev
task frontend:verify
task frontend:image:build
```

From `components/example-frontend`, use the component tasks:

```bash
npm ci
task dev
task verify
```

Vite always listens on container port 5173. In the developer container it is
published on `http://127.0.0.1:5173` by default. Set `FRONTEND_HOST_PORT` when
starting the developer container to choose another host port, for example
`FRONTEND_HOST_PORT=5174 ./dev.sh rebuild`. Changing it requires recreating the
developer container. The agent container publishes no ports.

`Taskfile.yml` exposes `dev`, `build`, `test`, `check`, and `verify` commands.

## Container Image

The frontend is built into `dist/` and packaged as an `example-frontend` OCI
image using an unprivileged Nginx runtime. The image serves the application on
port 8080.

From `components/example-frontend`:

```bash
task image:build
task image:push
task image:release
```

Development image tags include the current Git commit and dirty state. Release
images use the package version and require an exact matching Git tag.
