---
title: Document the greeting configuration
status: done
---

## Goal

The backend reads `greeting.message` and `greeting.secret`, configured
externally as `GREETING_MESSAGE` and `GREETING_SECRET`. A developer
should be able to find what they do and how to set them without reading
the code.

## Acceptance criteria

- `docs/` describes both properties, their environment variables, their
  defaults, and which are required.
- The description states that values are supplied outside this workspace.
