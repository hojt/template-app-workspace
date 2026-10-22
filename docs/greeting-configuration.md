# Greeting Configuration

The backend greeting is configured through environment variables. Deployment
values are supplied outside this workspace; environment-specific Kubernetes
configuration is owned by `local-environments`.

| Property | Environment variable | Default | Required |
| --- | --- | --- | --- |
| `greeting.message` | `GREETING_MESSAGE` | `Hello from Quarkus` | No |
| `greeting.secret` | `GREETING_SECRET` | `no-secret` | No |

`GREETING_MESSAGE` changes the message returned by `GET /api/greeting`.
`GREETING_SECRET` marks the secret as configured without returning its value in
the response.

For local development, set the variables when starting the backend:

```bash
GREETING_MESSAGE="Hello from config" GREETING_SECRET="example-secret" task backend:dev
```
