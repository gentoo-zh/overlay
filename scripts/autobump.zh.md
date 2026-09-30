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
* 每个版本都要单独生成 vendor bundle、但 overlay.toml 没写明来源的包（见 [vendor bundle](#vendor-bundle)）。

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

## vendor bundle

有些 ebuild 从 `gentoo-zh/gentoo-deps` 或某个 `gentoo-zh-drafts` 仓库的 release 下载按版本生成的 vendor bundle（Go vendor、crates、node_modules、pub cache）。overlay.toml 写明它由谁生成。

由 `gentoo-deps` 生成器生成的 bundle 只需要一个 `deps` 键，值是生成器的 `LANG`：

```toml
["net-proxy/zashboard"]
source = "github"
github = "Zephyruso/zashboard"
prefix = "v"
deps = "javascript"
```

release tag 是 `{P}`，上游仓库取 `github`，上游 tag 是 `prefix` 加版本号，与 nvchecker 从 tag 得出版本号的规则一致。生成器需要更多输入时写成 table：

| 键 | 含义 |
|---|---|
| `lang` | `golang`、`javascript`、`javascript(pnpm)`、`rust` 或 `dart` |
| `vendordir` | 生成器的 `VENDORDIR`，可省略 |
| `workdir` | 生成器的 `WORKDIR`，可省略 |
| `modules` | 每个子目录一个 bundle，release 名为 `{PN}-<module>-{PV}` |
| `repo`、`tag` | 上游仓库和 tag；nvchecker 不追踪 GitHub，或用 `from_pattern` 改写 tag 时必须写 |

```toml
deps = { lang = "golang", vendordir = "{P}" }
deps = { lang = "golang", modules = ["service", "core"] }
```

由自有 workflow 生成的 bundle，例如 `gentoo-zh-drafts` 各仓库，使用完整的 `bundle` 写法，每个 inline table 写在一行内：

```toml
bundle = [
  { id = "node_modules", repo = "gentoo-zh-drafts/deepseek-harness", workflow = "node_modules.yml", tag = "v{bundle_pv}", inputs = { version = "{bundle_pv}" } },
]
```

| 键 | 含义 |
|---|---|
| `id` | bundle 名称，在同一个包内唯一 |
| `repo` | `gentoo-zh` 或 `gentoo-zh-drafts` 下的 `owner/name` |
| `workflow` | 没有 release 带这个 tag 时 dispatch 的 workflow 文件 |
| `tag` | ebuild 下载所用的 release tag |
| `inputs` | `workflow_dispatch` 的输入，可省略 |
| `producers` | release 完整之前必须完成的全部 workflow，须包含 `workflow`，可省略，默认为 `workflow` |

值中可以使用 `{PN}`、`{PV}`、`{P}` 和 `{bundle_pv}`。`bundle_pv` 按顺序对版本号做字面替换 `[from, to]`：`bundle_pv = [["_rc", "-rc."]]` 把 `0.2.0_rc2` 变成 `0.2.0-rc.2`。两种写法都由 bundle 控制器读取，即 autobump-rb 的 `bin/bundles.py`；有无效条目时，它的 `list` 命令以非零状态退出。

producer run 的分支就是这个 tag，或者它的 run name 以完整单词的形式包含这个 tag、去掉开头 `v` 的 tag 或 `${P}` 时，这个 run 才归属该 tag。因此由 `workflow_dispatch` 启动的 producer 需要在 `run-name` 中写出版本。

### 状态

规划 shard 之前，autobump 检查每个 open nvchecker issue 的 bundle，只要该包有 `deps` 或 `bundle`，无论是否开启 `autobump`。只有 ready 的目标会分到 bump shard，那里的引擎通过 `--bundle-status` 读取快照。

* **ready**：release 已存在，且没有这个 tag 的 producer run 在排队或执行。
* **pending**：有 producer run 在排队或执行；或者两者都没有，规划阶段已 dispatch 该 workflow。同一版本的每个 bundle 最多 dispatch 三次，指向同一版本的多个 issue 和重新执行的运行都计入这个次数。回应丢失或返回 5xx 的 dispatch 也计入，因为 GitHub 可能已经启动了 run；返回 4xx 的不计入。
* **unknown**：GitHub 返回 401、403、429、5xx，或没有响应。不计次数，也不 dispatch；返回 401 或触发限流的 owner 在本次运行中不再请求。限流（429，或带 `retry-after`、`x-ratelimit-remaining: 0` 的 403）只输出警告，等下一次运行重新请求；其他 unknown 会让本次运行以失败结束，所以持续存在的故障不会被忽略。
* **escalate**：计入四次观察仍未 ready，workflow 拒绝 dispatch 或不存在，或者 `deps`、`bundle` 条目无效。issue 上会收到一条评论，附 bundle 仓库、producer run 和 `bundles.yml` 链接；之后在 bundle ready 或重试该 issue 之前不再处理。

bundle ready 之后，其 URI 的 404 由引擎判断：producer 完成不到 15 分钟时继续等待，超过后转交人工，这通常说明 ebuild 写错了文件名。这类等待计为一次观察，不占用暂时性重试次数。

计数记录在 `bundles` ledger 中，与 `done.list`、`attempts` 放在一起；`retry` 会让指定 issue 重新计数。一次观察指一次发现目标尚未 ready 的 autobump 运行，与目标有几个 bundle、距上次运行多久无关。控制器执行失败、没有留下有效快照时，有 bundle 的目标都不做 bump，其他包照常 bump，本次运行以失败结束并给出控制器的错误。

### 手动检查或准备 bundle

[Actions → bundles → Run workflow](https://github.com/gentoo-zh/overlay/actions/workflows/bundles.yml)：`packages` 填 atom，空格分隔；`version` 默认取最新的 ebuild；`mode` 为 `status`（只读）或 `prepare`（dispatch 缺少的 bundle）。

```bash
gh workflow run bundles.yml --repo gentoo-zh/overlay -f packages=net-dns/ddns-go -f mode=prepare

# 本地在 overlay 根目录执行，需要引擎已 clone 到该目录、gh 已登录
python3 autobump-rb/bin/bundles.py where net-dns/ddns-go
python3 autobump-rb/bin/bundles.py status dev-util/deepseek-harness --version 0.2.0_rc2
python3 autobump-rb/bin/bundles.py list --markdown
```

`bundles.yml` 或本地执行的 `prepare` 不写入 autobump ledger。需要记入 ledger 时，用 `bundles_only` 执行 autobump：它准备队列中或指定 issue 的 bundle，不做 bump。各 producer 仍可单独 dispatch。

### 引入 bundle 控制器之前卡住的 issue

在此之前，bundle 尚未发布时，autobump 会把 404 当作上游文件缺失转交人工，或在三次暂时性重试后放弃，ledger 中这个版本随之成为终态。open 的 nvchecker issue 若在状态评论中针对 `gentoo-zh/gentoo-deps` 或 `gentoo-zh-drafts` 下的 URI 报告了这种情况，用 `retry` 重试一次：

```bash
gh workflow run autobump.yml --repo gentoo-zh/overlay -f issues="11855 11860" -f retry=true
```

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

# 只准备队列中的 vendor bundle，不做 bump
gh workflow run autobump.yml --repo gentoo-zh/overlay -f bundles_only=true
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
