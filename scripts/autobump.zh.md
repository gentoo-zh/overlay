# autobump 使用说明

[English](autobump.md)

对 nvchecker 报告的新版本自动做 bump。

## 工作原理

1. nvchecker 发现新版本，开一个 issue。
2. 引擎判定这次升级是不是纯机械的：只改版本号，还是要动依赖、USE 或 patch。
3. 判定为机械的，就改版本号、重新生成 Manifest，在 CI 容器里跑一次真实 emerge。
4. emerge 通过才创建 PR。PR 仍要通过 `emerge-on-pr` 和 `pkgcheck`，由人 review 后合并。

第 2 步有三种结果：

* **可机械处理**：只改版本号且 emerge 通过，创建 PR。
* **需人工处理**：大版本跳变、依赖有变化、`files/` 里的 patch 要重新验证，或上游对 distfile 返回 404 或 403。因为上游没有这个文件，重试也不会成功，所以直接交给人。只在 issue 上记录证据，完整证据目录作为 run artifact 上传，不创建 PR。
* **暂缓**：网络或镜像暂时不可用（超时、连接被重置、5xx），per-version vendor bundle 还没生成（下载前检查其 URL 返回 404），或者某个过重的依赖在 binhost 上没有 binpkg、从源码编译会超出 CI 限时。下次自动重试，重试若干次仍不行才交给人。

## 哪些包可以开启

适合：

* `-bin` 预编译包，升级只是换一个 tarball。
* 单文件源码包，没有 vendor 依赖。
* vendor bundle 内容稳定的 rust 或 npm 包。

不适合：

* 依赖会随版本变化的包。
* 带 `files/` patch 的包，因为 patch 每次都要重新验证。
* 每个版本都要单独生成 vendor bundle 的包。

不确定就先做 build-test：Actions → autobump-trial → Run workflow，`targets` 填 nvchecker issue 号，空格分隔。每个目标会在 CI 容器里跑一遍真实的 bump、emerge、install 和 pkgcheck，汇报 PASS、DEFER（暂时性问题，值得重试）或 FAIL，不创建 PR。

## 开启和关闭

在 [`.github/workflows/overlay.toml`](../.github/workflows/overlay.toml) 中给该包加一行 `autobump = true`：

```toml
["net-proxy/mihomo"]
source = "github"
github = "MetaCubeX/mihomo"
autobump = true          # 添加此行开启，删除即关闭
```

没有这一行的包不会被 bump，所以某个包频繁产生错误的 PR 时，删掉这行就能停掉它。

`autobump` 的值同时决定 bump 后保留几个版本：`true` 只删除被新版本取代的那一个，更早的版本不动；`N` 保留包括新版本在内的最近 N 个版本，更早的全部删除，所以 `1` 只留新版本；`"all"` 保留全部。`0` 与 `true` 相同。

## SRC_URI 依赖 ebuild 变量的包

`app-editors/cursor` 的 `SRC_URI` 由 `MY_COMMIT` 构造。仅改版本号无法获取文件。配置正则后，`autobump` 在复制 ebuild 后、生成 Manifest 前替换该变量：

```toml
["app-editors/cursor"]
source = "regex"
url = "https://cursor.com/api/download?platform=linux-x64&releaseTrack=latest"
regex = '"version":"([\d.]+)"'
autobump = true
autobump_my_commit_regex = '"commitSha":"([0-9a-f]{40})"'
```

`autobump_my_commit_regex` 中的 `my_commit` 对应 ebuild 变量 `MY_COMMIT`，值取第一个捕获组，默认从该条目的 `url` 获取。正则和 URL 都支持 `${PV}`，替换为目标版本：

```toml
autobump_my_build_regex = '"version":"${PV}","execution_id":"([0-9]+)"'
autobump_my_build_url = "https://example.org/releases/${PV}"
```

正则使用 TOML 单引号字面字符串。无法读取值、正则不匹配或新值与旧值相同时，不改写 ebuild，也不 bump。

## 运行

`master` 上的 nvchecker 每次运行结束 60 秒后执行，留出时间让 GitHub 搜索收录新开的 issue；另有每天 11:00 UTC 一次作为兜底。因为 autobump 处理的是所有 open 的 issue，所以 nvchecker 运行失败时照常执行，只有运行被取消时才跳过。

### 网页

[Actions → autobump → Run workflow](https://github.com/gentoo-zh/overlay/actions/workflows/autobump.yml)

### 使用 gh

```bash
# 处理所有 open 的 nvchecker issue
gh workflow run autobump.yml --repo gentoo-zh/overlay

# 只处理指定 issue，空格分隔
gh workflow run autobump.yml --repo gentoo-zh/overlay -f issues="11855 11860"

# 调整本次上限
gh workflow run autobump.yml --repo gentoo-zh/overlay -f limit=20
```

两种方式的输入相同，`issues` 只接受数字和空格。

worker 跑在每天构建一次的镜像里（`autobump-env`）。`rebuild_env` 强制重建，`env_date` 指定用更早一天的镜像，保留最近三个。

`limit` 限制这次运行自己挑出来的引擎尝试数，默认 0 表示整个队列都跑；手动指定的 issue 号不受它限制，全部都会尝试。规划阶段按缓存状态解析队列，把这些尝试分到互不重叠的 shard，跳过不占额度。

一次运行分三段：规划、最多八个并行的 bump worker、合并。每个 worker 最多 360 分钟，到时由 GitHub 取消。每个计时操作各有两小时上限，`ebuild install`、`emerge` 和 `ebuild unpack` 超时后标记暂缓、下次重试，所以一个包可能在 worker 的六小时里用掉好几个两小时。

本地运行先把引擎 clone 到 overlay 根目录、安装 `dev-lang/ruby`：

```bash
AUTOBUMP_ENGINE='ruby autobump-rb/bin/autobump' \
    python3 scripts/autobump-sweep.py [issue#...] [--limit N] [--pr]
```

某次运行处理了哪些 issue、各自结果如何，见那次 Actions run 日志末尾的 sweep summary。

---

引擎实现、判定细节、部署与运维见引擎仓库：[autobump-rb](https://github.com/gentoo-zh/autobump-rb)。
