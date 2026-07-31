<div align="right">

[English](./README.md) | 简体中文 | [正體中文](./README.zh-TW.md)

</div>

# gentoo-zh

Overlay for Gentoo Users.\
gentoo-zh 是一个包容的 overlay。

> [!NOTE]
> gentoo-zh overlay 已迁移至 https://github.com/gentoo-zh/overlay 。旧的 GitHub URL 会继续重定向。如果你手动配置过 remote，可以在方便时更新。
> 详情请参见 [MIGRATION.md](./MIGRATION.md)。

## 社区

[![官网](https://img.shields.io/badge/%E5%AE%98%E7%BD%91-gentoozh.org-54487A?logo=gentoo&logoColor=white)](https://gentoozh.org/)
[![GitHub Issues](https://img.shields.io/badge/GitHub-Issues-181717?logo=github)](https://github.com/gentoo-zh/overlay/issues)
[![Email](https://img.shields.io/badge/Email-overlay%40gentoozh.org-EA4335?logo=maildotcom&logoColor=white)](mailto:overlay@gentoozh.org)
[![论坛](https://img.shields.io/badge/%E8%AE%BA%E5%9D%9B-forum.gentoozh.org-000000?logo=discourse&logoColor=white)](https://forum.gentoozh.org/)
[![维基](https://img.shields.io/badge/%E7%BB%B4%E5%9F%BA-Gentoo--zh-54487A?logo=gentoo&logoColor=white)](https://wiki.gentoo.org/wiki/Gentoo-zh/zh-cn)
[![Telegram 群组](https://img.shields.io/badge/%E7%BE%A4%E7%BB%84-gentoo__zh-26A5E4?logo=telegram&logoColor=white)](https://t.me/gentoo_zh)
[![公告频道](https://img.shields.io/badge/%E5%85%AC%E5%91%8A-gentoocn-26A5E4?logo=telegram&logoColor=white)](https://t.me/gentoocn)
[![Matrix](https://img.shields.io/badge/Matrix-%23gentoo--zh-000000?logo=matrix&logoColor=white)](https://matrix.to/#/%23gentoo-zh:matrix.gentoozh.org)
[![IRC](https://img.shields.io/badge/IRC-%23gentoo--zh-5A5A5A?logo=liberadotchat&logoColor=white)](https://web.libera.chat/#gentoo-zh)

overlay 的问题优先走 GitHub Issues。

## 如何将此 overlay 添加到 Gentoo Linux

```
eselect repository enable gentoo-zh
emaint sync
```

中国大陆镜像加速相关请参考：https://gentoozh.org/overlay/

## distfiles 与二进制包

部分软件包提供 distfiles 与二进制包，每晚触发构建，配置和镜像参考：https://distfiles.gentoozh.org

## 依赖关系表

https://github.com/gentoo-zh/overlay/blob/deps-table/relation.md

## 贡献

**不要破坏用户的系统。**

* 我们欢迎所有人贡献，但请提交者在提交前谨慎确认。
* PR 中的每个提交都要包含所需的所有修改，不要无故拆分，例如 ebuild 和它的 `Manifest` 要在同一个提交里。
* 每个 ebuild 修改在提交前要确保编译正确。
* 新增的软件包需要添加到 [`.github/workflows/overlay.toml`](./.github/workflows/overlay.toml) 中，并按照 `category/package` 的字母顺序插入相应位置；如果该软件包不适合使用 nvchecker 检查版本更新，请在对应位置添加注释并说明原因；如果可以自动 bump，参见 [scripts/autobump.zh.md](./scripts/autobump.zh.md)。
* 在打开 pull request 前，请先在本地运行 `pkgcheck scan --commits --net`。
* 开 pull request 之后，请检查并修正 pkgcheck report 和 CI 报出的错误，QA 提示也要处理。
* CI 会在 amd64 和 arm64 上构建。如果在你没有的架构上出现无法解决的问题，请移除那个 keyword。
* 新增的软件包请持续维护，并使用 [pull request 模板](./.github/pull_request_template.md)。
* 不再维护自己的软件包时，请在 issues 里找新维护者，或者在 [`profiles/package.mask`](./profiles/package.mask) 里 mask，到期后再移除。

### 提交信息

建议用 `pkgdev commit` 生成提交信息。版本升级格式如下：

```
$category/$package: add $new_version, drop $old_version
```

其他改动格式如下：

```
$category/$package: one line short description message

multiple lines of description about why you change this.
if you change to fix the bug, and if there is an GitHub
issue entry for that bug, then point the bug link here.
```

## AI 政策

可以用生成式 AI 辅助，但它必须遵守 [AGENTS.md](./AGENTS.md)，且每个提交由贡献者负责：确保 ebuild 的质量和验证功能正确，ebuild 要实际做一遍冒烟测试再提交，pull request 描述要简短、精准、专业，写实测结果而不是猜测。贡献者、提交者与提交作者必须是人类，不能是 AI 工具或模型身份。
