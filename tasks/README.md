# Tasks

Work for the coding agents, recorded as one document per task. See
ADR-0012 in `hojt/homelab`.

## Format

Each task is a Markdown file named after the task, such as
`greeting-error-state.md`:

```markdown
---
title: Show an error state when the greeting cannot be loaded
status: open
---

## Goal

What should be true when the task is done, and why.

## Acceptance criteria

- Observable outcomes that show the task is done.

## Notes

Optional context, constraints, or pointers.
```

## Status

| Status | Meaning |
| --- | --- |
| `proposed` | Suggested by the agent and not yet accepted. |
| `open` | Accepted and ready to be worked on. |
| `done` | Completed by a merged change. |
| `closed` | Not going to be done. |

## Backlog

`BACKLOG.md` lists the tasks that should be done, in order. The first
open task in it is the next one. The developer owns the order.

## Lifecycle

- The developer creates a task with status `open` and commits it, adding
  it to the backlog if it should be done soon.
- The agent works on it on a branch named `agent/<task-name>`. In the
  same branch, it sets the status to `done` and removes the task from the
  backlog.
- A task with an `agent/<task-name>` branch is in progress, and is
  skipped when the agent takes the next task.
- The task is closed when the developer merges the branch.
- The agent may propose a task on a branch named `agent/propose-<task-name>`,
  with status `proposed`, without changing the backlog. The developer
  accepts it by setting the status to `open` and merging the branch.

Keep sensitive work, such as unresolved security issues, out of this
directory.
