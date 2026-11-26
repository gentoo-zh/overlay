<div align="right">

</div>

# 贡献指南

gentoo-zh 是 Gentoo 的 overlay（第三方 ebuild 仓库），依赖 `::gentoo`（`metadata/layout.conf` 中 `masters = gentoo`）。

## 软件包

- ebuild 只使用 `~arch` 关键字；
- `::gentoo` 已有的依赖不在本仓库重复添加；除特殊情况外，不添加与 `::gentoo` 同名的软件包；
- 每个软件包须有 `metadata.xml`，并写明维护者；
- `LICENSE` 须与所打包软件声明的许可证一致，`::gentoo` 没有的许可证须加入 `licenses/` 和 `profiles/license_groups`；
- 除特殊情况外，同一软件包的改动须在同一个提交中；
- 软件包须登记到 `.github/workflows/overlay.toml`，依 `category/package` 的字母顺序插入，不适合 nvchecker 的须注释原因；
- 可自动更新版本的软件包见 [scripts/autobump.zh.md](./scripts/autobump.zh.md)；
- ebuild 提交前须进行测试；
- 不再维护的软件包，须在 issue 中寻找接手者。无人接手的且无法通过编译的，依据 [last rites](https://devmanual.gentoo.org/ebuild-maintenance/removal/) 流程移除：在 `profiles/package.mask` 顶部加入条目，写明作者、邮箱、日期（UTC）、原因和移除日期，至少 30 天后移除。范例：

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

所有改动经 pull request 合并，禁止直接推送 master 或绕过 CI。

提交遵循 [Gentoo git workflow](https://wiki.gentoo.org/wiki/Gentoo_git_workflow)：

- 第一行为摘要行，格式为 `category/package: 摘要`，不超过 69 个字符；
- 正文可选；如有正文，须与摘要行之间空一行；
- 须附 `Signed-off-by:`，可用 `pkgdev commit --signoff` 添加；
- 版本更新的格式为 `category/package: add 0.5, drop 0.4`；
- pull request 中不得有 merge commit，同步 master 时使用 `git rebase`，不使用 `git merge`。

范例：

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
pkgcheck scan --commits --net    # 发起 pull request 前检查本分支的提交
```

> [!NOTE]
> `pkgdev commit` 的 `-b` 和 `-c` 会引用到 bugs.gentoo.org，不要用于本仓库的 issue。

### pull request 描述

须使用 pull request 模板：

- 描述写在 `<!-- Please put the pull request description above -->` 之上；
- 关闭本仓库的 issue 时，在描述中加入 `Closes #N`；
- 改动了软件包、`eclass/`、`profiles/` 或 `licenses/` 时，须勾选 pkgcheck；如果使用了 AI，须勾选 AI。

范例：

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
> 发起 pull request 后，须修复 pkgcheck 报告和 CI 发现的问题，包括 QA 提示。

## AI 政策

允许使用 AI，但须满足以下要求：

- 使用 AI 辅助时须遵守 [AGENTS.md](./AGENTS.md)；
- 贡献者须理解 AI 生成的内容；
- `Signed-off-by` 须由贡献者本人添加，不得由工具添加；
- 添加 `Signed-off-by` 前，贡献者须确认 AI 生成的部分没有复制许可证不兼容的代码；
- AI 生成的提交信息和 pull request 描述须准确、精简、不重复，所述内容须经验证。

```
pkgdev commit --signoff -m "fix build with GCC 16" -m "Add a missing include." -T Assisted-by:Deepseek-v4.1-Flash
```

生成的提交信息：

```
app-misc/foo: fix build with GCC 16

Add a missing include.

Assisted-by: Claude:claude-opus-5-5
Signed-off-by: A Developer <example@gentoo.org>
```

以下情况无需声明：

- 小改动或机械性改动；
- 仅使用 AI 审查贡献者自己的改动，并由贡献者自行修复 AI 发现的问题。

### 禁止

- 由工具发出 pull request、推送或评论，而贡献者未逐条阅读并批准。
- 根据工具输出批量发起 pull request，而未逐个构建和测试。
- 隐瞒或淡化 AI 的参与程度。

autobump、nvchecker 等本仓库自有的 bot 不受上述规则限制。

### 测试

AI 生成的改动与其他改动适用相同的测试要求，ebuild 须经过冒烟测试。不得声称执行了实际未执行的测试。


