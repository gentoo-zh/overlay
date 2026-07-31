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
  re-verify, or a missing per-version vendor bundle. It comments the evidence on the
  issue and opens no PR.
* **defer** — a transient network, mirror or upstream-file problem, or a heavy
  dependency with no binpkg on the binhost that would exceed the CI timeout. Retried
  automatically.

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
install and pkgcheck in the CI container and reports PASS or FAIL, without opening a PR.

The `autobump-recommend` workflow collects packages that look mechanically bumpable but
are not opted in into one issue, which is a good place to pick from. It only recommends;
nothing is enabled automatically.

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

`keep_old = N` alongside it keeps the N most recent versions instead of replacing the
top one. `app-misc/go-yq-bin` and `media-fonts/sarasa-gothic` use `keep_old = 2`;
`keep_old = 0` keeps every version.

## Running it

* Actions → autobump → Run workflow. An empty `issues` field processes every open
  nvchecker issue and skips the ones not opted in; `limit` caps how many this run does.
* Locally, clone the engine into the overlay root, install `dev-lang/ruby`, then run
  `AUTOBUMP_ENGINE='ruby autobump-rb/bin/autobump' bash scripts/autobump-sweep.sh
  [issue#...] [--limit N] [--pr]`.
* The cron at the top of `autobump.yml` is commented out. Uncomment it once a few manual
  runs look stable.

Which issues a run processed and how each came out is in the sweep summary at the end of
that Actions run log.

---

Engine internals, classification, deploy and ops:
[autobump-rb](https://github.com/gentoo-zh/autobump-rb).
