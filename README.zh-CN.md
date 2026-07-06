[English](./README.md) | 简体中文 | [正體中文](./README.zh-TW.md)

> [!NOTE]
> gentoo-zh overlay 已迁移至 https://github.com/gentoo-zh/overlay 。旧的 GitHub URL 会继续重定向。如果你手动配置过 remote，可以在方便时更新。

## 仓库迁移

本仓库通过 GitHub repository transfer 从 `microcai/gentoo-zh` 转移到 `gentoo-zh` 组织，随后又重命名为 `gentoo-zh/overlay`。

当前仓库地址：

https://github.com/gentoo-zh/overlay

详情请参见 [MIGRATION.md](./MIGRATION.md)。

# 如何将此 overlay 添加到 Gentoo 系统

```
eselect repository enable gentoo-zh
emaint sync
```

# 规则一

不要破坏用户的系统。

# 规则二

不要破坏用户的系统。

# 规则三

遵守规则一和规则二。

# 依赖关系表

https://github.com/gentoo-zh/overlay/blob/deps-table/relation.md

# 提交信息

建议使用 `pkgdev commit` 快速生成提交信息。

* 对于非版本升级提交，提交信息格式应类似：

        $category/$package: one line short description message
        {empty line}
        multiple lines of description about why you change this.
        if you change to fix the bug, and if there is an GitHub
        issue entry for that bug, then point the bug link here.

* 对于版本升级提交，提交信息格式应类似：

        $category/$package: add $new_version, drop $old_version

# 贡献

* 我信任拥有提交权限的贡献者，因此提交者在提交前应谨慎确认。

* 可以使用生成式 AI 辅助 ebuild 维护，但贡献者必须确保相关 ebuild
  修改的质量。尤其要在修改后验证功能正确性；包括 CLI、GUI 等应用形态在内的应用，
  都应在提交前进行适当的冒烟测试。即便使用生成式 AI 辅助维护，贡献者仍然是每个提交的第一责任人。
  贡献者、提交者与提交作者必须是人类，不能是 Codex、GPT、Claude、Gemini 等 AI 工具或模型身份，
  也不能是类似系统。

* 如果你要发起新的 pull request，请确保其中包含单个贡献所需的所有提交，
  例如不要把一个 ebuild 和它的 `Manifest` 拆成两个 pull request。

* 每个 ebuild 修改在提交前都不应导致编译错误。

* 每个 ebuild 都应在其 `KEYWORDS` 声明的每个 ARCH 上测试。
  如果没有测试，就不要声称支持该 keyword。

* 每个 ebuild 都应使用 ~arch keywords，不得使用 stable keywords。

* 在打开 pull request 前，请先在本地运行 `pkgcheck scan --commits --net`。

# Distfiles 镜像

我们提供 distfiles 镜像，用于缓存 gentoo-zh 的 distfiles。

我们的服务器托管在美国：
```
GENTOO_MIRRORS="${GENTOO_MIRRORS} https://distfiles.gentoozh.org"
```

重庆大学镜像：
```
GENTOO_MIRRORS="${GENTOO_MIRRORS} https://mirrors.cqu.edu.cn/gentoo-zh"
```

南京大学镜像：
```
GENTOO_MIRRORS="${GENTOO_MIRRORS} https://mirrors.nju.edu.cn/gentoo-zh"
```
