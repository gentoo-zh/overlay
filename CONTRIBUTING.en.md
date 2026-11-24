<div align="right">

English | [简体中文](./CONTRIBUTING.md) | [正體中文](./CONTRIBUTING.zh-TW.md)

</div>

# Contributing

gentoo-zh is a Gentoo overlay (a third-party ebuild repository) that depends on
`::gentoo` (`masters = gentoo` in `metadata/layout.conf`).

> [!NOTE]
> Anyone who deliberately bypasses the rules in this file is removed from the
> organization, and all packages they maintain are treecleaned. This applies to
> all maintainers, including owners and members.

## Packages

- Ebuilds use `~arch` keywords only.
- Dependencies that `::gentoo` already provides are not duplicated here, and a
  package with the same name as one in `::gentoo` is not added unless there is a
  specific reason.
- Every package has a `metadata.xml` that names its maintainer.
- `LICENSE` matches the license declared by the packaged software; add licenses
  missing from `::gentoo` to `licenses/` and `profiles/license_groups`.
- Unless there is a specific reason, keep the changes to one package in one
  commit.
- Register packages in `.github/workflows/overlay.toml`, inserted in
  alphabetical order by `category/package`; comment the reason for any that
  nvchecker cannot track.
- For packages that can be bumped automatically, see
  [scripts/autobump.md](./scripts/autobump.md).
- Test ebuilds before committing.
- For a package you no longer maintain, find a new maintainer in the issues. If
  nobody takes it, remove it through
  [last rites](https://devmanual.gentoo.org/ebuild-maintenance/removal/): add an
  entry at the top of `profiles/package.mask` with your name, email, date (UTC),
  reason and removal date, and remove the package after 30 days or more, for
  example:

  ```
  # Zakk <zakk@gentoozh.org> (2026-11-18)
  # Upstream archived.
  # Removal on 2026-12-18.
  net-proxy/daed
  ```

References:

- [Devmanual](https://devmanual.gentoo.org/)
- [GLEP 66](https://www.gentoo.org/glep/glep-0066.html): git workflow and commit messages
- [GLEP 76](https://www.gentoo.org/glep/glep-0076.html): copyright policy and `Signed-off-by`
- [pkgdev](https://pkgcore.github.io/pkgdev/), [pkgcheck](https://pkgcore.github.io/pkgcheck/)

## Commits

All changes go through pull requests. Do not push to master or bypass CI.

Commits follow the
[Gentoo git workflow](https://wiki.gentoo.org/wiki/Gentoo_git_workflow):

- The first line is the summary line, `category/package: summary`, at most 69
  characters.
- The body is optional; if present, separate it from the summary line with a
  blank line.
- Add `Signed-off-by:`; `pkgdev commit --signoff` adds it.
- Version bumps are written as `category/package: add 0.5, drop 0.4`.
- No merge commits in a pull request; sync with master using `git rebase`, not
  `git merge`.

Example:

```
app-misc/foo: fix build with GCC 16

Add a missing include.

Signed-off-by: A Developer <example@gentoo.org>
```

Common commands:

```
pkgdev manifest                  # update the Manifest
pkgcheck scan --net              # check the current changes
pkgdev commit --signoff          # commit with a generated summary and Signed-off-by
pkgdev commit --signoff -m "fix build with GCC 16" -m "Add a missing include."
                                 # custom summary and body
pkgcheck scan --commits --net    # check the branch's commits before the pull request
```

> [!NOTE]
> `pkgdev commit -b` and `-c` refer to bugs.gentoo.org; do not use them for this
> repository's issues.

### Pull request descriptions

Use the pull request template:

- Write the description above
  `<!-- Please put the pull request description above -->`.
- To close an issue of this repository, add `Closes #N` to the description.
- If you changed a package, `eclass/`, `profiles/` or `licenses/`, you must
  check the pkgcheck box; if you used AI, you must check the AI box.

Example:

```
Because upstream 1.2.3 fixes a crash on Wayland, add it.

Closes #12345

<!-- Please put the pull request description above -->

---

Please check all the boxes that apply:

- [x] I have run `pkgcheck scan --commits --net` to check for issues with my commits.
- [x] If I used AI: I understand every change, tested it and take responsibility for it; commits with AI-written changes carry `Assisted-by:`.

Please note that all boxes must be checked for the pull request to be merged.
```

> [!NOTE]
> After opening the pull request, fix the problems reported by pkgcheck and CI,
> including QA warnings.

## AI policy

AI may be used, provided that:

- work done with AI follows [AGENTS.md](./AGENTS.md);
- the contributor understands what the AI writes;
- contributors add `Signed-off-by` themselves; a tool must never add it;
- before adding `Signed-off-by`, the contributor confirms that the AI-written
  parts copy no code under an incompatible license;
- AI-written commit messages and pull request descriptions are accurate,
  concise and free of repetition, with every claim verified.

### Disclosure

A commit containing AI-written changes must carry an `Assisted-by:` trailer in
the [Linux kernel format](https://docs.kernel.org/process/coding-assistants.html),
`Assisted-by: AGENT:MODEL`, above `Signed-off-by:`. Add it with
`pkgdev commit -T`:

```
pkgdev commit --signoff -m "fix build with GCC 16" -m "Add a missing include." -T Assisted-by:Claude:claude-opus-5-5
```

The resulting commit message:

```
app-misc/foo: fix build with GCC 16

Add a missing include.

Assisted-by: Claude:claude-opus-5-5
Signed-off-by: A Developer <example@gentoo.org>
```

> [!NOTE]
> Do not add `Co-authored-by:`; CI rejects it.

Disclosure is not required for:

- small or mechanical changes;
- using AI only to review the contributor's own change, when the contributor
  fixes the issues it finds.

### Forbidden usage

- Having an automated tool directly open pull requests or post comments before
  a human contributor has confirmed a successful build, verified that the tests
  pass and reviewed each piece of tool-generated content.
- Hiding or understating the extent of AI involvement.

This repository's own bots, such as autobump and nvchecker, are not covered by
these rules.

### Testing

AI-written changes are subject to the same testing requirements as any other
change, and ebuilds must be smoke-tested. Do not claim to have run a test that
was not run.

### Enforcement

If we suspect that AI was used without disclosure, we will ask for an
explanation, and the contributor must answer truthfully. If they refuse, we will
close the pull request or issue. This rule also applies to maintainers.

Agents can use [gentoo-zh/skills](https://github.com/gentoo-zh/skills) for
packaging, version bumps and reviews. They apply AGENTS.md and add no rules of
their own. Install them with:

```
npx skills add gentoo-zh/skills -g
```

This section is adapted from
[OpenWrt packages' AI policy](https://github.com/openwrt/packages/blob/master/CONTRIBUTING.md#ai-policy).
