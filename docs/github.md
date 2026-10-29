# Moving A Workspace To GitHub

The coding agent can deliver through GitHub instead of the local delivery
repository. See ADR-0013 in `hojt/homelab` for the decision.

## On GitHub

- Push the repository to GitHub. On a free personal account, repository
  rulesets apply only to public repositories; without them nothing keeps
  the app from updating the default branch.
- Install the coding-agent GitHub App on the repository, with only this
  repository selected.
- Add three repository rulesets. The app must not be in any bypass list.
  1. **Default branch:** restrict updates, restrict deletions, block force
     pushes, and require a pull request with one approval, dismissing stale
     approvals on new commits. Bypass: Repository admin, for pull requests
     only.
  2. **All branches except `agent/**` and the default branch:** restrict
     creations, updates, and deletions. Bypass: Repository admin, always.
  3. **All tags:** restrict creations, updates, and deletions. Bypass:
     Repository admin, always.
- Make sure workflows triggered by pull requests use no secrets and only
  read access to the repository.

## On the host

- `~/.config/agent-github/app.conf` sets `github_app_id` and
  `github_app_key`, the path to the app's private key, readable only by you.
- `openssl` is available on the host or in a toolbox.

## In the workspace

- Before switching, fetch any branches the agent has delivered locally with
  `./agent.sh fetch`, and merge or discard them.
- In `.devcontainer/agent/sandbox.conf`, set `agent_forge=github` and
  `agent_forge_repository=<owner>/<name>`.
- Run `./agent.sh rebuild` and check that every check passes. Mounts are
  chosen when the agent container is created, so switching `agent_forge`
  requires recreating it.

## Verify the rules

Before relying on them, check with the app's token that pushing to `main`
and pushing a tag are rejected, and that pushing an `agent/` branch works:

```bash
./agent.sh github-token
token="$(cat "${XDG_RUNTIME_DIR}/agent-github/<workspace>/token")"
cd "$(mktemp -d)"
git clone "https://x-access-token:${token}@github.com/<owner>/<name>" .

git commit --allow-empty -m "test: push to main as the app"
git push origin main                      # must be rejected

git switch -c agent/rules-test
git push origin agent/rules-test          # must succeed
git tag rules-test
git push origin rules-test                # must be rejected

git push origin --delete agent/rules-test
cd ~
unset token
```

Do not continue until `main` and the tag are rejected.
