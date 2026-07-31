# autobump 使用说明

[English](autobump.md)

对 nvchecker 报告的新版本自动做 bump。

## 工作原理

1. nvchecker 发现新版本，开一个 issue。
2. 引擎判定这次升级是不是纯机械的：只改版本号，还是要动依赖、USE 或 patch。
3. 判定为机械的，就改版本号、重新生成 Manifest，在 CI 容器里跑一次真实 emerge。
4. emerge 通过才创建 PR。PR 照样要过 `emerge-on-pr` 和 `pkgcheck`，由人 review 后合并。

第 2 步有三种结果：

* **可机械处理**：只改版本号且 emerge 通过，创建 PR。
* **需人工处理**：大版本跳变、依赖有变化、`files/` 里的 patch 要重新验证，或缺少 per-version vendor bundle。只在 issue 上记录证据，不创建 PR。
* **暂缓**：网络、镜像或上游文件暂时不可用，或者某个过重的依赖在 binhost 上没有 binpkg、从源码编译会超出 CI 限时。下次自动重试。

## 哪些包可以开启

适合：

* `-bin` 预编译包，升级只是换一个 tarball。
* 单文件源码包，没有 vendor 依赖。
* vendor bundle 内容稳定的 rust 或 npm 包。

不适合：

* 依赖会随版本变化的包。
* 带 `files/` patch 的包，因为 patch 每次都要重新验证。
* 每个版本都要单独生成 vendor bundle 的包。

不确定就先做 build-test：Actions → autobump-trial → Run workflow，`targets` 填 nvchecker issue 号，空格分隔。每个目标会在 CI 容器里跑一遍真实的 bump、emerge、install 和 pkgcheck，汇报 PASS 或 FAIL，不创建 PR。

`autobump-recommend` workflow 会把看起来可机械 bump 但尚未开启的包汇总到同一个 issue 里，可以从那里挑。它只是推荐，不会自动开启。

## 开启和关闭

在 [`.github/workflows/overlay.toml`](../.github/workflows/overlay.toml) 中给该包加一行 `autobump = true`：

```toml
["net-proxy/mihomo"]
source = "github"
github = "MetaCubeX/mihomo"
autobump = true          # 添加此行开启，删除即关闭
```

没有这一行的包不会被 bump，所以某个包频繁产生错误的 PR 时，删掉这行就能停掉它。

再加一行 `keep_old = N`，bump 时就保留最近 N 个版本，而不是只替换最新那一个。`app-misc/go-yq-bin` 和 `media-fonts/sarasa-gothic` 用 `keep_old = 2`；`keep_old = 0` 表示保留全部版本。

## 运行方式

* Actions → autobump → Run workflow。`issues` 留空表示处理所有 open 的 nvchecker issue，未开启的会跳过；`limit` 是本次处理数量的上限。
* 本地运行先把引擎 clone 到 overlay 根目录、安装 `dev-lang/ruby`，然后执行 `AUTOBUMP_ENGINE='ruby autobump-rb/bin/autobump' bash scripts/autobump-sweep.sh [issue#...] [--limit N] [--pr]`。
* `autobump.yml` 顶部的 cron 默认是注释掉的。手动运行几次确认稳定后再取消注释。

某次运行处理了哪些 issue、各自结果如何，见那次 Actions run 日志末尾的 sweep summary。

---

引擎实现、判定细节、部署与运维见引擎仓库：[autobump-rb](https://github.com/gentoo-zh/autobump-rb)。
