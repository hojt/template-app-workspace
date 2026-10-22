# Agent Instructions

This repository contains a complete application workspace.

## Responsibilities

Application source code, tests, build tooling, and application-level
documentation belong in this repository.

Kubernetes desired state belongs in `local-environments`.

Platform implementation belongs in `local-platform`.

Do not introduce platform or environment configuration into this repository.

## Development

Use repository Task commands as the preferred development interface when
available.

Keep independently deployable components independently buildable and testable.

Changes may span multiple application components and workspace-level development
tooling when required by a feature.

Validate changes before considering work complete.

## Development environments

The repository provides separate development environments for the human
developer and for the coding agent.

`dev.sh` starts the developer environment. Development servers that a human
developer needs to inspect from the host may be exposed through this environment.

When adding such a server:

- configure the server to listen on the container network interface rather than
  container-local loopback;
- expose its port from the developer container on host loopback only
  (`127.0.0.1`);
- keep the exposure limited to the developer environment;
- ensure that the normal repository Task command starts the service correctly
  inside the development environment.

`agent.sh` starts the coding-agent environment.

Do not expose development server ports from the agent environment.

The agent is responsible for implementing and validating the application and
for configuring the developer-environment plumbing needed for human testing.
The agent is not responsible for verifying that a service is reachable from the
host.

Host reachability is verified by the human developer after starting the
developer environment with `dev.sh`.

Workspace-level development plumbing, including the devcontainer configuration,
may be changed when required to make a component usable from the developer
environment. Keep such changes minimal and specific to demonstrated needs.

Dependencies are not shared with the developer environment. Run `npm install`
in a frontend component before building or testing it.

### Agent containment

The development environment is intentionally designed to contain the
coding agent and limit its blast radius. The workspace-specific layout
is described in `.devcontainer/agent/sandbox.conf`, and `agent.sh`
verifies it, together with the containment properties below, before
starting an agent or an agent shell. See ADR-0010 in `hojt/homelab` for
the reasoning.

Do not attempt to bypass, weaken, or escape this containment. When a
restriction stands in the way of a task, suggest the change instead of
working around it.

The agent environment does not expose:

- the host Podman socket
- the host Kubernetes configuration
- the host Git configuration or SSH agent
- container-runtime connection environment variables
- direct network access

What to expect inside the sandbox:

- The workspace is your own clone, created from the developer's
  repository, which is available read-only as `origin`. The developer's
  working tree is not visible to you.
- `.opencode/` and `.claude/` are agent-only tmpfs mounts. Git is set to
  ignore that they hide the `README.md` files kept in the repository.
- Paths listed as hidden in `sandbox.conf` appear empty on purpose.
- Network access goes through an egress proxy with an allowlist. A
  refused connection is intended, not a fault to fix.

If you notice configuration or architectural issues that could
unintentionally grant the agent broader access or capabilities than
intended, point them out clearly so they can be reviewed by the human
developer.

Do not add privileged host, container-runtime, Kubernetes-cluster,
host-network, or similar access to the agent environment unless the
human developer explicitly requests it for a concrete reason.

## Git

You work in your own clone of this repository and deliver your work as
branches. See ADR-0011 in `hojt/homelab`.

- Start each task on a new branch from the latest default branch:

      git fetch origin
      git switch -c agent/<topic> origin/main

- Branch names must start with `agent/`. Other branches are not delivered.
- Keep commits focused, with messages following Conventional Commits.
- Deliver your work by pushing the branch with `git push`. This pushes to
  your delivery repository, not to the developer's repository.
- You may amend or rebase your own `agent/` branches. Never push to
  `origin`, rewrite the default branch, or create tags.
- The developer reviews, merges, tags, and publishes. Delivered branches
  are never merged automatically.
- When asked to remove a delivered branch, run
  `git push delivery --delete agent/<topic>`.
- You see committed work only. If you need changes the developer has not
  committed, ask for them to be committed.
- When asked to rebase a delivered branch, run `git fetch origin`,
`git rebase origin/main`, and `git push --force-with-lease`.
- When a task is delivered, switch back to the default branch with
  `git switch main`.

## Tasks

Work is recorded as tasks in `tasks/`. See `tasks/README.md` for the
format, and ADR-0012 in `hojt/homelab` for the reasoning.

- Run `git fetch origin` before choosing a task, so that you see the
  developer's latest tasks and backlog.
- Work on the task the developer names. When asked to take the next
  task, take the first task with status `open` in `tasks/BACKLOG.md`.
  Do not start tasks that are not in the backlog unless the developer
  names them.
- Work on one task per branch, named `agent/<task-name>`, starting from
  `origin/main`.
- When the task is complete, in the same branch, set its status to `done`
  and remove it from the backlog, then deliver the branch.
- If you discover work outside the current task, propose it as a new task
  on its own branch, `agent/propose-<task-name>`, with status `proposed`.
  Do not change the backlog, and do not mix proposals into task branches.
- Write proposed tasks as descriptions of work for the developer to
  review, not as instructions to future agent sessions.

## Architecture

Prefer the smallest useful implementation.

Do not introduce abstractions, shared packages, services, or repository
boundaries for speculative future requirements.

Components remain in this workspace until a demonstrated need for independent
ownership or evolution justifies extracting them.
