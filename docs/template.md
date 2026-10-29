# Template Ownership

Application workspaces keep `template-app-workspace` as an upstream and merge
its released versions. See ADR-0014 in `hojt/homelab`.

## Files owned by the template

These files are the same in every application workspace. Do not change them in
an application; change them in the template, and merge a new template version.

- `agent.sh` and `dev.sh`
- `.devcontainer/`, except the files listed as starting points below
- `.template/`
- `opencode.json` and `CLAUDE.md`
- `.opencode/README.md` and `.claude/README.md`
- `tasks/README.md`
- `docs/template.md`, `docs/create-application.md`, and `docs/github.md`

## Starting points

These files belong to the application once it has been created. The template
provides them as a starting point and changes them only when necessary.

- `README.md` and `AGENTS.md`
- `Taskfile.yml`, `scripts/`, and `components/`
- `tasks/BACKLOG.md` and task documents
- `.devcontainer/devcontainer.json`, the developer environment
- `.devcontainer/agent/sandbox.conf` and `.devcontainer/agent/sandbox.allowlist`
- `.gitignore`
- everything else under `docs/`

## Versions

Template versions are tags named `vMAJOR.MINOR.PATCH`. A major version may
require manual steps when merged; its tag message describes them.

Merge a version into an application from its developer container:

    task template:update -- v1.0.0

Show the versions an application has merged:

    task template:status

## Changing the template

The template's default branch is what every application merges. Develop and
test changes on a branch or in a copy, validate them in `example-app`, and tag
a version only when they are ready.
