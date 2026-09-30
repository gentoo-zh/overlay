# autobump

[简体中文](autobump.zh.md)

Bumps the new versions nvchecker reports.

## How it works

1. nvchecker finds a new version and opens an issue.
2. The engine decides whether the bump is purely mechanical: a version change only, or
   something that needs dependencies, USE flags or patches touched.
3. If it is mechanical, it changes the version, regenerates the Manifest and runs a real
   emerge in the CI container.
4. Only a passing emerge opens a PR. That PR still goes through `emerge-on-pr` and
   `pkgcheck`, and a human reviews and merges it.

Step 2 has three outcomes:

* **mechanical** — version change only and emerge passed, so it opens a PR.
* **escalate** — major version jump, changed dependencies, a `files/` patch to
  re-verify, or a distfile upstream answers with 404 or 403, because the file is not
  there and a retry cannot fix that. It comments the evidence on the issue, uploads
  the engine's evidence directory as a run artifact, and opens no PR.
* **defer** — a transient network or mirror problem (timeout, reset connection, 5xx),
  a per-version vendor bundle that is not generated yet (its URL answers 404 before
  the fetch), or a heavy dependency with no binpkg on the binhost that would exceed
  the CI timeout. Retried automatically.

## Which packages to opt in

Suitable:

* `-bin` packages, where a bump is just a different tarball.
* Single-file source packages with no vendored dependencies.
* rust or npm packages whose vendor bundle is stable.

Not suitable:

* Packages whose dependencies change between versions.
* Packages carrying `files/` patches, because every patch has to be re-verified.
* Packages needing a vendor bundle generated per version.

When in doubt, build-test first: Actions → autobump-trial → Run workflow, with `targets`
set to nvchecker issue numbers separated by spaces. Each target gets a real bump, emerge,
install and pkgcheck in the CI container and reports PASS, DEFER (transient, worth retrying) or
FAIL, without opening a PR.

## Opting in and out

Add `autobump = true` to the package in
[`.github/workflows/overlay.toml`](../.github/workflows/overlay.toml):

```toml
["net-proxy/mihomo"]
source = "github"
github = "MetaCubeX/mihomo"
autobump = true          # add to enable, remove to disable
```

Packages without the line are never bumped, so removing it is how you stop one that
keeps opening bad PRs.

The value of `autobump` also sets how many versions remain after a bump: `true` drops only
the version the new one replaces and leaves older ones alone; `N` keeps the N most recent
versions, the new one included, and drops everything older, so `1` keeps only the new version;
`"all"` keeps every version. `0` behaves like `true`.

## Packages whose SRC_URI depends on an ebuild variable

`app-editors/cursor` builds `SRC_URI` from `MY_COMMIT`, so a version-only copy fetches nothing.
One regex makes autobump replace that variable after it copies the ebuild and before it
regenerates the Manifest:

```toml
["app-editors/cursor"]
source = "regex"
url = "https://cursor.com/api/download?platform=linux-x64&releaseTrack=latest"
regex = '"version":"([\d.]+)"'
autobump = true
autobump_my_commit_regex = '"commitSha":"([0-9a-f]{40})"'
```

The `my_commit` in the key is `MY_COMMIT`, the value is capture group 1, and the document
defaults to the entry's own `url`. Both accept `${PV}`, replaced with the version being bumped
to:

```toml
autobump_my_build_regex = '"version":"${PV}","execution_id":"([0-9]+)"'
autobump_my_build_url = "https://example.org/releases/${PV}"
```

Write the regex as a TOML literal (single-quoted) string. If the document cannot be fetched, the
regex does not match, or the value equals the current one, nothing is rewritten and nothing is
bumped.

## Running it

It runs 60 seconds after each nvchecker run on `master` finishes, so GitHub search lists
the new issues, and daily at 11:00 UTC as a backstop. Because it works from the open
issues, a failed nvchecker run still starts it; only a cancelled one does not.

### Web

[Actions → autobump → Run workflow](https://github.com/gentoo-zh/overlay/actions/workflows/autobump.yml)

### With gh

```bash
# every open nvchecker issue
gh workflow run autobump.yml --repo gentoo-zh/overlay

# only these issues, space separated
gh workflow run autobump.yml --repo gentoo-zh/overlay -f issues="11855 11860"

# change the cap for this run
gh workflow run autobump.yml --repo gentoo-zh/overlay -f limit=20
```

Both take the same inputs; `issues` accepts digits and spaces only.

The workers run in an image built once a day (`autobump-env`). `rebuild_env` forces a fresh
one; `env_date` runs on an earlier day's image, of which the last three are kept.

`limit` caps engine attempts on work the run picks itself; it defaults to 0, which runs the
whole queue, and issue numbers given by hand are always all attempted. The planner resolves the queue against the cached state and assigns those attempts to
disjoint shards; skips are free.

A run has three phases: plan, at most eight bump workers in parallel, and collect. Each worker
lasts at most 360 minutes and GitHub cancels it there. Each timed operation - `ebuild install`, `emerge`,
`ebuild unpack` - has a two-hour ceiling of its own and is deferred on timeout, so one package
can spend several of them inside the worker's six hours.

Locally, clone the engine into the overlay root, install `dev-lang/ruby`, then run:

```bash
AUTOBUMP_ENGINE='ruby autobump-rb/bin/autobump' \
    python3 scripts/autobump-sweep.py [issue#...] [--limit N] [--pr]
```

Which issues a run processed and how each came out is in the sweep summary at the end of
that Actions run log.

---

Engine internals, classification, deploy and ops:
[autobump-rb](https://github.com/gentoo-zh/autobump-rb).
