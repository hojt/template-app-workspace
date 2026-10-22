.---
title: Let the user retry loading the greeting
status: open
---

## Goal

When the greeting cannot be loaded, the frontend shows an error state.
The user should be able to try again without reloading the page.

## Acceptance criteria

- The error state includes a button that retries loading the greeting.
- A successful retry replaces the error state with the greeting.
- A test covers a failed load followed by a successful retry.
- `task frontend:verify` passes.
