<div align="right">

English | [简体中文](./README.md) | [正體中文](./README.zh-TW.md) | [廣東話](./README.zh-HK.md)

</div>

# gentoo-zh

Overlay for Gentoo Users.\
gentoo-zh is an inclusive overlay.

> [!NOTE]
> gentoo-zh overlay has moved to https://github.com/gentoo-zh/overlay. Old GitHub URLs continue to redirect. If you manually configured a remote, update it when convenient.
> See [MIGRATION.md](./MIGRATION.md) for details.

## Community

[![Website](https://img.shields.io/badge/Website-gentoozh.org-54487A?logo=gentoo&logoColor=white)](https://gentoozh.org/en/)
[![GitHub Issues](https://img.shields.io/badge/GitHub-Issues-181717?logo=github)](https://github.com/gentoo-zh/overlay/issues)
[![Email](https://img.shields.io/badge/Email-overlay%40gentoozh.org-EA4335?logo=maildotcom&logoColor=white)](mailto:overlay@gentoozh.org)
[![Forum](https://img.shields.io/badge/Forum-forum.gentoozh.org-000000?logo=discourse&logoColor=white)](https://forum.gentoozh.org/)
[![Wiki](https://img.shields.io/badge/Wiki-Gentoo--zh-54487A?logo=gentoo&logoColor=white)](https://wiki.gentoo.org/wiki/Gentoo-zh)
[![Telegram group](https://img.shields.io/badge/Telegram%20group-gentoo__zh-26A5E4?logo=telegram&logoColor=white)](https://t.me/gentoo_zh)
[![Announcements](https://img.shields.io/badge/Announcements-gentoocn-26A5E4?logo=telegram&logoColor=white)](https://t.me/gentoocn)
[![Matrix](https://img.shields.io/badge/Matrix-%23gentoo--zh-000000?logo=matrix&logoColor=white)](https://matrix.to/#/%23gentoo-zh:matrix.gentoozh.org)
[![IRC](https://img.shields.io/badge/IRC-%23gentoo--zh-5A5A5A?logo=liberadotchat&logoColor=white)](https://web.libera.chat/#gentoo-zh)

For anything about the overlay, GitHub Issues is preferred.

## How to add this overlay to Gentoo Linux

```
eselect repository enable gentoo-zh
emaint sync
```

Mirrors for mainland China: https://gentoozh.org/en/overlay/

## Distfiles and binary packages

Some packages come with distfiles and prebuilt binary packages, built nightly.
Setup and mirrors: https://distfiles.gentoozh.org

## Dependency table

https://github.com/gentoo-zh/overlay/blob/deps-table/relation.md

## Contributions

**DO NOT BREAK PEOPLE'S SYSTEM.**

* Everyone is welcome to contribute, but committers should check their work
  carefully before committing.
* Every commit in a pull request must carry all the changes it needs; do not split a
  change across commits without reason, e.g. an ebuild and its `Manifest` belong in
  the same commit.
* Every ebuild change must compile before committing.
* A new package must be added to
  [`.github/workflows/overlay.toml`](./.github/workflows/overlay.toml), inserted in
  alphabetical order by `category/package`; if it is not suitable for nvchecker to
  check for new versions, add a comment in that position explaining why; if it can be
  bumped automatically, see [scripts/autobump.md](./scripts/autobump.md).
* Run `pkgcheck scan --commits --net` locally before you open a pull request.
* After opening the pull request, fix whatever the pkgcheck report and CI flag, QA
  warnings included.
* CI builds on amd64 and arm64. If a problem shows up on an arch you do not have and
  you cannot solve it, remove that keyword.
* Keep maintaining the packages you add, and use the
  [pull request template](./.github/pull_request_template.md).
* When you stop maintaining a package, look for a new maintainer in the issues, or
  mask it in [`profiles/package.mask`](./profiles/package.mask) and drop it when the
  mask expires.

### Commit messages

We recommend generating them with `pkgdev commit`. Version bump:

```
$category/$package: add $new_version, drop $old_version
```

Anything else:

```
$category/$package: one line short description message

multiple lines of description about why you change this.
if you change to fix the bug, and if there is an GitHub
issue entry for that bug, then point the bug link here.
```

## AI policy

Generative AI may assist, but it must follow [AGENTS.md](./AGENTS.md) and the
contributor is responsible for every commit: ensure the quality of the ebuild and
verify that it works, smoke-test it before submitting, and keep the pull request
description short, precise and professional, written from tested results, not
guesses. The contributor, submitter, and commit author must be a human, not an AI
tool or model identity.
