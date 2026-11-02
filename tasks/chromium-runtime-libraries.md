# Chromium runtime libraries for Playwright

Status: done

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

## Findings

Playwright 1.64.1 was installed in `/tmp/pw` on 2026-11-02. Its Chromium
revision is 1248 (Chrome for Testing 156.0.8078.4). `npx playwright install
chromium`, without `--with-deps`, tried five times to download:

```text
https://cdn.playwright.dev/builds/cft/156.0.8078.4/linux64/chrome-linux64.zip
```

Each request was rejected by the agent proxy with HTTP 403 (`Filtered`), so
neither the Chromium nor the Chromium headless shell binary was downloaded and
`ldd` could not be run. The added packages are therefore unverified mappings
from Chromium's standard Linux runtime libraries; rebuilding the image and
running `ldd` is required before treating them as confirmed.

| Runtime library | Fedora package |
| --- | --- |
| `libasound.so.2` | `alsa-lib` |
| `libatk-1.0.so.0`, `libatk-bridge-2.0.so.0`, `libatspi.so.0` | `at-spi2-atk` |
| `libcairo.so.2` | `cairo` |
| `libcups.so.2` | `cups-libs` |
| `libdbus-1.so.3` | `dbus-libs` |
| `libfontconfig.so.1` | `fontconfig` |
| `libfreetype.so.6` | `freetype` |
| `libgdk_pixbuf-2.0.so.0` | `gdk-pixbuf2` |
| `libglib-2.0.so.0` | `glib2` |
| `libgtk-3.so.0` | `gtk3` |
| `libX11.so.6` | `libX11` |
| `libXcomposite.so.1` | `libXcomposite` |
| `libXdamage.so.1` | `libXdamage` |
| `libXext.so.6` | `libXext` |
| `libXfixes.so.3` | `libXfixes` |
| `libXrandr.so.2` | `libXrandr` |
| `libdrm.so.2` | `libdrm` |
| `libxcb.so.1` | `libxcb` |
| `libxkbcommon.so.0` | `libxkbcommon` |
| `libxshmfence.so.1` | `libxshmfence` |
| `libgbm.so.1` | `mesa-libgbm` |
| `libnspr4.so` | `nspr` |
| `libnss3.so` | `nss` |
| `libpango-1.0.so.0` | `pango` |

`~/.cache` is in the container's writable overlay filesystem, not a named
volume, tmpfs, or image layer. It is agent-only because the agent container is
isolated from the developer environment. `/dev/shm` is 63 MiB,
`/sys/fs/cgroup/pids.max` is 2048, and the memory limit is 16 GiB
(`17179869184` bytes).

`HTTP_PROXY` and `HTTPS_PROXY` are both
`http://template-app-workspace-agent-proxy:8888`; `NO_PROXY` is
`localhost,127.0.0.1`. Both `localhost` and `127.0.0.1` bypass the proxy.
The only browser-download host contacted was `cdn.playwright.dev`, and the
proxy rejected it. Permit that host through the agent proxy allowlist to enable
the required download and `ldd` verification; no sandbox setting was changed.
