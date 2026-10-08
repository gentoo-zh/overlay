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
* Packages needing a vendor bundle generated per version, unless overlay.toml says where it
  comes from (see [Vendor bundles](#vendor-bundles)).

When in doubt, build-test first: Actions → autobump-trial → Run workflow, with `targets`
set to nvchecker issue numbers separated by spaces. Each target gets a real bump, emerge,
install and pkgcheck through `scripts/autobump-trial.sh` in the `autobump-env` image. It reports
PASS, DEFER (transient, worth retrying) or FAIL without opening a PR.

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

## Vendor bundles

Some ebuilds download a per-version vendor bundle (Go vendor, crates, node_modules, pub cache)
from a release of `gentoo-zh/gentoo-deps` or a `gentoo-zh-drafts` repository. overlay.toml says
where it comes from.

A bundle from the `gentoo-deps` generator takes one `deps` key, the generator's `LANG`:

```toml
["net-proxy/zashboard"]
source = "github"
github = "Zephyruso/zashboard"
prefix = "v"
deps = "javascript"
```

The release tag is `{P}`, the upstream repository is `github`, and the upstream tag is `prefix`
followed by the version, the same mapping nvchecker applies. A table adds generator inputs:

| key | meaning |
|---|---|
| `lang` | `golang`, `javascript`, `javascript(pnpm)`, `rust` or `dart` |
| `vendordir` | the generator's `VENDORDIR`, optional |
| `workdir` | the generator's `WORKDIR`, optional |
| `modules` | one bundle per subdirectory, released as `{PN}-<module>-{PV}` |
| `repo`, `tag` | the upstream repository and tag, required when nvchecker does not track GitHub or rewrites the tag with `from_pattern` |

```toml
deps = { lang = "golang", vendordir = "{P}" }
deps = { lang = "golang", modules = ["service", "core"] }
```

A bundle from a producer with its own workflow, as in the `gentoo-zh-drafts` repositories, takes
the full `bundle` form, one inline table per bundle:

```toml
bundle = [
  { id = "node_modules", repo = "gentoo-zh-drafts/deepseek-harness", workflow = "node_modules.yml", tag = "v{bundle_pv}", inputs = { version = "{bundle_pv}" } },
]
```

| key | meaning |
|---|---|
| `id` | a name for the bundle, unique within the package |
| `repo` | `owner/name` under `gentoo-zh` or `gentoo-zh-drafts` |
| `workflow` | the workflow file dispatched when no release carries the tag |
| `tag` | the release tag the ebuild downloads from |
| `inputs` | the `workflow_dispatch` inputs, optional |
| `producers` | every workflow that must finish for the release to be complete, `workflow` included, optional; defaults to `workflow` |

Values take `{PN}`, `{PV}`, `{P}` and `{bundle_pv}`. `bundle_pv` applies literal `[from, to]`
replacements to the version in order: `bundle_pv = [["_rc", "-rc."]]` turns `0.2.0_rc2` into
`0.2.0-rc.2`. The bundle controller, autobump-rb's `bin/bundles.py`, reads both forms; its
`list` command exits non-zero on an invalid entry.

A producer run belongs to the tag when its branch is the tag, or when its run name contains the
tag, the tag without a leading `v`, or `${P}` as a whole word. A producer started by
`workflow_dispatch` therefore needs a `run-name` that names the version.

### States

Before planning the shards, autobump checks the bundles of every open nvchecker issue whose
package has `deps` or `bundle`, opted in or not. Only a ready target reaches a bump shard,
where the engine reads the snapshot with `--bundle-status`.

* **ready**: the release exists and no producer run for the tag is queued or running.
* **pending**: a producer run is queued or running, or the plan dispatched the workflow because
  there was neither. A bundle of one version is dispatched at most three times, counted across
  issues naming that version and across re-runs; a dispatch whose reply was lost or a 5xx counts,
  a 4xx does not.
* **unknown**: GitHub answered 401, 403, 429 or 5xx, or not at all. Nothing is counted or
  dispatched, and an owner that answered 401 or rate limited is not asked again in that run.
  Rate limiting (429, or 403 with `retry-after` or `x-ratelimit-remaining: 0`) logs a warning
  and waits for the next run; any other unknown ends the run failed, so a failure that persists
  does not go unseen.
* **escalate**: four observations without ready, a workflow that refused the dispatch or does
  not exist, or an invalid `deps` or `bundle` entry. The issue gets one comment with the bundle
  repository, the producer run and `bundles.yml`, and stays there until the bundle is ready or
  the issue is retried.

For a ready bundle, the engine judges a 404 on its URI: it waits if the producer finished less
than 15 minutes ago and escalates after that, which usually means the ebuild names the wrong
file. Such a wait counts as an observation, not a transient retry.

The counts live in the `bundles` ledger next to `done.list` and `attempts`; `retry` starts a
named issue's count over. An observation is one autobump run that finds the target not ready,
however many bundles it has and however long ago the previous run was. When the controller fails and leaves no valid snapshot, bundle targets
are held back, other packages are still bumped, and the run ends failed with the controller's
error.

### Checking or preparing a bundle by hand

[Actions → bundles → Run workflow](https://github.com/gentoo-zh/overlay/actions/workflows/bundles.yml)
takes `packages` (atoms separated by spaces), `version` (default: the newest ebuild) and `mode`,
either `status` (read only) or `prepare` (dispatch what is missing).

```bash
gh workflow run bundles.yml --repo gentoo-zh/overlay -f packages=net-dns/ddns-go -f mode=prepare

# locally, from the overlay root with the engine cloned into it and gh logged in
python3 autobump-rb/bin/bundles.py where net-dns/ddns-go
python3 autobump-rb/bin/bundles.py status dev-util/deepseek-harness --version 0.2.0_rc2
python3 autobump-rb/bin/bundles.py list --markdown
```

A `prepare` from `bundles.yml` or a shell does not write the autobump ledger. To prepare through
the ledger, run autobump with `bundles_only`: it prepares the bundles of the queue or the named
issues and bumps nothing. Each producer can still be dispatched on its own.

### Issues stuck before the bundle controller

Before the controller existed, an unpublished bundle made autobump escalate the 404 as a missing
upstream file or give up after three transient tries, and the ledger keeps that version terminal.
For an open nvchecker issue whose status comment reports this for a URI under
`gentoo-zh/gentoo-deps` or `gentoo-zh-drafts`, run it once with `retry`:

```bash
gh workflow run autobump.yml --repo gentoo-zh/overlay -f issues="11855 11860" -f retry=true
```

## Running it

It runs after each nvchecker run on `master` finishes, and daily at 11:00 UTC as a backstop. Because it works from the open
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

# prepare the queue's vendor bundles, bump nothing
gh workflow run autobump.yml --repo gentoo-zh/overlay -f bundles_only=true
```

Both take the same inputs; `issues` accepts digits and spaces only.

The workers run in an image built once a day (`autobump-env`). `rebuild_env` forces a fresh
one; `env_date` runs on an earlier day's image, of which the last three are kept.

The workflow gives each package a fresh container, with at most eight jobs running at once;
the remaining jobs wait for a slot. `limit` caps automatically selected attempts; 0 adds no cap.
Manual issue lists ignore `limit`, but both modes stop at GitHub's matrix limit of 256 jobs.
Skips do not count toward this limit. Any excess eligible packages remain for a later run.

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
