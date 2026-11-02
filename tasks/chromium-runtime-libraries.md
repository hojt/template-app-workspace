# Chromium runtime libraries for Playwright

Status: open

## Background

Applications created from the template will run Playwright end-to-end tests
with Chromium, in both the developer environment and the coding-agent
environment. Playwright does not support Fedora officially, and
`playwright install-deps` requires root, which the coding-agent environment
does not have. The system libraries Chromium needs must therefore be installed
in the agent image when it is built.

Only Chromium is in scope. Firefox and WebKit are not supported.

## Goal

Determine which Fedora packages Chromium needs, add them to the agent image,
and report the sandbox settings that affect running Chromium.

## Steps

1. In a scratch directory outside the repository, for example `/tmp/pw`,
   install `@playwright/test` and run `npx playwright install chromium`
   without `--with-deps`. Record the Playwright version used. Do not add
   Playwright to any file in the repository.
2. Run `ldd` on the downloaded Chromium and Chromium headless shell binaries
   and list every library reported as `not found`.
3. Map each missing library to the Fedora package that provides it. Mark any
   mapping you could not verify as unverified.
4. Add the packages to the package installation step of the agent image in
   `.devcontainer/agent/`. Change only the package list. Keep the packages
   sorted and group them under a comment that names Playwright and Chromium.
5. Add a `Findings` section to this document with:
   - the Playwright version, and the `ldd` output that the package list is
     based on;
   - where `~/.cache` is stored in the agent container (volume, tmpfs, or
     image layer), and whether it is agent-only;
   - the size of `/dev/shm`, the pids limit (`/sys/fs/cgroup/pids.max`), and
     the memory limit;
   - the values of `HTTP_PROXY`, `HTTPS_PROXY`, and `NO_PROXY`, and whether
     `localhost` and `127.0.0.1` bypass the proxy;
   - which hosts the browser download contacted or failed to contact.
   Propose changes to settings as findings; do not make them.

## Out of scope

- Changes to `agent.sh`, `sandbox.conf`, `sandbox.allowlist`, the agent
  `devcontainer.json`, shared agent instructions, or agent tool settings.
- The developer environment.
- Firefox, WebKit, `install-deps`, and anything that requires root.

## Done when

- The branch `agent/chromium-runtime-libraries` contains the package list
  change and the findings, and marks this task as done.
- Every added package is justified by the `ldd` output in the findings.

The developer rebuilds the agent image, confirms that `ldd` reports no missing
libraries, and validates with a minimal Playwright test in `example-app`.
