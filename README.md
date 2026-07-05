English | [简体中文](./README.zh-CN.md)

> [!NOTE]
> gentoo-zh overlay has moved to https://github.com/gentoo-zh/overlay. Old GitHub URLs continue to redirect. If you manually configured a remote, update it when convenient.

## Repository migration

This repository was transferred from `microcai/gentoo-zh` to the `gentoo-zh` organization through GitHub repository transfer, and later renamed to `gentoo-zh/overlay`.

The current repository is:

https://github.com/gentoo-zh/overlay

See [MIGRATION.md](./MIGRATION.md) for details.

# How to add this overlay to your Gentoo system

```
eselect repository enable gentoo-zh
emaint sync
```

# rule no.1

DO NOT BREAK PEOPLE'S SYSTEM

# rule no.2

DO NOT BREAK PEOPLE'S SYSTEM

# rule no.3

follow rule no.1 and no.2

# the dependencies table

https://github.com/gentoo-zh/overlay/blob/deps-table/relation.md

# commit message

It is recommended to run `pkgdev commit` to quickly generate commit messages.

* for non-version bump commit, commit message should be like this:

        $category/$package: one line short description message
        {empty line}
        multiple lines of description about why you change this.
        if you change to fix the bug, and if there is an GitHub
        issue entry for that bug, then point the bug link here.

* for version bump commit, commit message should be like this:

        $category/$package: add $new_version, drop $old_version

# Contributions

* I trust contributors that have commit rights, therefore commitors
  should think carefully before committing.

* Generative AI may be used to assist ebuild maintenance, but contributors must
  ensure the quality of related ebuild changes. In particular, verify functional
  correctness after modifications; applications, including CLI and GUI
  applications, should receive appropriate smoke testing through actual use
  before submission. Even when generative AI is used, the contributor remains
  the primary person responsible for every commit. The contributor, submitter,
  and commit author must be a human, not an AI tool or model identity such as
  Codex, GPT, Claude, Gemini, or similar systems.

* If you are sending a new pull request, make sure it contains all necessary commits
  for a single contribution, e.g. don't send two pull requests for an ebuild and its
  `Manifest`.

* Every ebuild change should not produce compile error before committing.

* Every ebuild should be tested in every ARCH that it KEYWORDS for.
  if not, don't claim that you support that keyword.

* Every ebuild is to have ~arch keywords. Stable keywords must not be used.

* Run `pkgcheck scan --commits --net` locally before you open pull request.

# Distfiles mirror

We provide a distfiles mirror that caches the distfiles in gentoo-zh.

Our server, hosted on USA:
```
GENTOO_MIRRORS="${GENTOO_MIRRORS} https://distfiles.gentoozh.org"
```

Chongqing University mirror:
```
GENTOO_MIRRORS="${GENTOO_MIRRORS} https://mirrors.cqu.edu.cn/gentoo-zh"
```

Nanjing University mirror:
```
GENTOO_MIRRORS="${GENTOO_MIRRORS} https://mirrors.nju.edu.cn/gentoo-zh"
```

# See wiki for some package not working
