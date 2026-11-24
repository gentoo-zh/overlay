<div align="right">

[English](./CONTRIBUTING.en.md) | 简体中文 | [正體中文](./CONTRIBUTING.zh-TW.md)

</div>

# 贡献指南

gentoo-zh 是 Gentoo 的 overlay（第三方 ebuild 仓库），依赖 `::gentoo`（`metadata/layout.conf` 中 `masters = gentoo`）。

> [!NOTE]
> 蓄意规避本文规定者将被移出组织，其维护的所有软件包也将被 treeclean。此规则适用于所有维护者，包括 owner 和 member。

## 软件包

- ebuild 只使用 `~arch` 关键字；
- `::gentoo` 已有的依赖不在本仓库重复添加；除特殊情况外，不添加与 `::gentoo` 同名的软件包；
- 每个软件包须有 `metadata.xml`，并写明维护者；
- `LICENSE` 须与所打包软件声明的许可证一致，`::gentoo` 没有的许可证须加入 `licenses/` 和 `profiles/license_groups`；
- 除特殊情况外，同一软件包的改动须放在同一个提交中；
- 软件包须登记到 `.github/workflows/overlay.toml`，按 `category/package` 的字母顺序插入，无法由 nvchecker 追踪的，需以注释说明原因；
- 可自动更新版本的软件包见 [scripts/autobump.zh.md](./scripts/autobump.zh.md)；
- ebuild 提交前须进行测试；
- 不再维护的软件包，须先发 issue 寻找接手者。无人接手的，依据 [last rites](https://devmanual.gentoo.org/ebuild-maintenance/removal/) 流程移除：在 `profiles/package.mask` 顶部加入条目，写明作者、邮箱、日期（UTC）、原因和移除日期，至少 30 天后移除。示例：

  ```
  # Zakk <zakk@gentoozh.org> (2026-11-18)
  # Upstream archived.
  # Removal on 2026-12-18.
  net-proxy/daed
  ```

参考：

- [Devmanual](https://devmanual.gentoo.org/)
- [GLEP 66](https://www.gentoo.org/glep/glep-0066.html)：git 工作流与提交信息
- [GLEP 76](https://www.gentoo.org/glep/glep-0076.html)：版权政策与 `Signed-off-by`
- [pkgdev](https://pkgcore.github.io/pkgdev/)、[pkgcheck](https://pkgcore.github.io/pkgcheck/)

## 提交

所有改动经 Pull Request 合并，禁止直接推送到 master 或绕过 CI。

提交遵循 [Gentoo git workflow](https://wiki.gentoo.org/wiki/Gentoo_git_workflow)：

- 首行为摘要，格式为 `category/package: 摘要`，不超过 69 个字符；
- 正文可选；如有正文，须与摘要行之间空一行；
- 须附 `Signed-off-by:`，可用 `pkgdev commit --signoff` 添加；
- 版本更新的格式为 `category/package: add 0.5, drop 0.4`；
- Pull Request 中不得有 merge commit，同步 master 时使用 `git rebase`，不使用 `git merge`。

示例：

```
app-misc/foo: fix build with GCC 16

Add a missing include.

Signed-off-by: A Developer <example@gentoo.org>
```

常用命令：

```
pkgdev manifest                  # 更新 Manifest
pkgcheck scan --net              # 检查当前改动
pkgdev commit --signoff          # 提交，生成摘要行并附 Signed-off-by
pkgdev commit --signoff -m "fix build with GCC 16" -m "Add a missing include."
                                 # 自定义摘要行和正文
pkgcheck scan --commits --net    # 发起 Pull Request 前检查本分支的提交
```

> [!NOTE]
> `pkgdev commit` 的 `-b` 和 `-c` 会关联到 bugs.gentoo.org，不要用于本仓库的 issue。

### Pull Request 描述

需按 Pull Request 模板填写：

- 描述写在 `<!-- Please put the pull request description above -->` 上方；
- 关闭本仓库的 issue 时，在描述中加入 `Closes #N`；
- 改动了软件包、`eclass/`、`profiles/` 或 `licenses/` 时，须勾选 pkgcheck 对应项；如果使用了 AI，须勾选 AI 声明项。

示例：

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
> 发起 Pull Request 后，须修复 pkgcheck 和 CI 报告的问题，包括 QA 警告。

## AI 政策

允许使用 AI，但须满足以下要求：

- 使用 AI 辅助时须遵守 [AGENTS.md](./AGENTS.md)；
- 贡献者须理解 AI 生成的内容；
- `Signed-off-by` 须由贡献者本人添加，不得由工具添加；
- 添加 `Signed-off-by` 前，贡献者须确认 AI 生成的部分没有复制许可证不兼容的代码；
- AI 生成的提交信息和 Pull Request 描述须准确、精简、无冗余，且所写内容须经核实。

### 声明

包含 AI 生成内容的提交，须在 `Signed-off-by:` 上方添加 `Assisted-by:` 行，格式遵循 [Linux 内核](https://docs.kernel.org/process/coding-assistants.html) 规范： `Assisted-by: 工具名:模型名`。用 `pkgdev commit -T` 添加：

```
pkgdev commit --signoff -m "fix build with GCC 16" -m "Add a missing include." -T Assisted-by:Claude:claude-opus-5-5
```

生成的提交信息：

```
app-misc/foo: fix build with GCC 16

Add a missing include.

Assisted-by: Claude:claude-opus-5-5
Signed-off-by: A Developer <example@gentoo.org>
```

> [!NOTE]
> 不得使用 `Co-authored-by:`，否则 CI 会拒绝该提交。

以下情况无需声明：

- 小改动或机械性改动；
- 仅使用 AI 审查自己的改动，并自行修复 AI 发现的问题。

### 禁止

- 在人类贡献者没有确认构建成功、通过测试和逐条审阅自动化工具生成的内容时，由自动化工具直接发起 Pull Request 或发表评论。
- 隐瞒或淡化 AI 的参与程度。

autobump、nvchecker 等本仓库自有的 bot 不受上述规则限制。

### 测试

AI 生成的改动与其他改动适用相同的测试要求，ebuild 须经过冒烟测试。不得虚报未实际进行的测试。

### 执行

如果怀疑贡献中使用了 AI 却未声明，我们会要求说明，贡献者须如实回答；拒绝说明的，我们会关闭该 Pull Request 或 issue。本规则同样适用于维护者。

AI agent 可使用 [gentoo-zh/skills](https://github.com/gentoo-zh/skills) 进行打包、更新版本和代码审查。该工具集仅落实 AGENTS.md 的规范，不额外增设规则。安装命令：

```
npx skills add gentoo-zh/skills -g
```

本节参考 [OpenWrt packages 的 AI 政策](https://github.com/openwrt/packages/blob/master/CONTRIBUTING.md#ai-policy)。
