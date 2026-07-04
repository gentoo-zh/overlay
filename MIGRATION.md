# gentoo-zh repository migration / gentoo-zh 仓库迁移说明

## 中文

gentoo-zh overlay 已通过 GitHub repository transfer 从个人仓库迁移到社区组织仓库：

- 原仓库：https://github.com/microcai/gentoo-zh
- 当前仓库：https://github.com/gentoo-zh/overlay

该仓库先从 microcai 个人账号 transfer 到 gentoo-zh 组织（当时为 `gentoo-zh/gentoo-zh`），随后经社区投票（21:9）定名并重命名为 `gentoo-zh/overlay`；`microcai/gentoo-zh` 和 `gentoo-zh/gentoo-zh` 两个旧地址都会一跳 301 直达新仓库（网页和 git 均可），现有用户不受影响。相关更新也已提交到 Gentoo 官方 overlay 登记（gentoo/api-gentoo-org#829）。

迁移完成后，`gentoo-zh/overlay` 是 gentoo-zh overlay 的正式维护入口。

过去所有维护者和用户对 gentoo-zh 的贡献会随仓库迁移一并保留。后续维护在 `gentoo-zh/overlay` 继续进行。

为了让仓库地址与当前维护入口保持一致，建议在方便时将本地 remote 更新为：

```bash
git remote set-url origin https://github.com/gentoo-zh/overlay.git
```

后续 issue、pull request 和维护讨论请使用当前仓库。

## English

The gentoo-zh overlay has been transferred from the personal repository to the community organization through GitHub repository transfer:

- Previous repository: https://github.com/microcai/gentoo-zh
- Current repository: https://github.com/gentoo-zh/overlay

The repository was first transferred from microcai's personal account to the gentoo-zh organization (then `gentoo-zh/gentoo-zh`), and later renamed to `gentoo-zh/overlay` following a community poll (21 vs 9); both `microcai/gentoo-zh` and `gentoo-zh/gentoo-zh` 301-redirect to the new repository in a single hop (web and git), so existing users are not affected. A corresponding update has been submitted to the Gentoo overlay registry (gentoo/api-gentoo-org#829).

After the transfer, `gentoo-zh/overlay` is the main repository for the gentoo-zh overlay.

Contributions from past maintainers and users are preserved as part of this repository transfer. Future maintenance continues at `gentoo-zh/overlay`.

To keep local remotes aligned with the current maintenance location, update them when convenient:

```bash
git remote set-url origin https://github.com/gentoo-zh/overlay.git
```

Please use the current repository for future issues, pull requests, and maintenance discussions.
