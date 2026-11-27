<div align="right">

[English](./CONTRIBUTING.en.md) | [简体中文](./CONTRIBUTING.md) | 正體中文

</div>

# 貢獻指南

gentoo-zh 是 Gentoo 的 overlay（第三方 ebuild 儲存庫），依賴 `::gentoo`（`metadata/layout.conf` 中 `masters = gentoo`）。

> [!NOTE]
> 蓄意規避本文規則者將被禁止提交。此規則適用於所有維護者，包括 owner 和 member。

## 套件

- ebuild 只使用 `~arch` 關鍵字；
- 如無特殊情況，`::gentoo` 已有的套件不在本儲存庫重複新增；
- 每個套件須有 `metadata.xml`，並寫明維護者；
- `LICENSE` 須與所打包軟體聲明的授權條款一致，`::gentoo` 沒有的授權條款須加入 `licenses/` 和 `profiles/license_groups`；
- 除特殊情況外，同一套件的改動須放在同一個提交中；
- 套件須登記到 `.github/workflows/overlay.toml`，依 `category/package` 的字母順序插入，無法由 nvchecker 追蹤的，需以註解說明原因；
- 可自動更新版本的套件見 [scripts/autobump.zh.md](./scripts/autobump.zh.md)；
- 提交前請先在本機進行測試，測試通過後才可開啟 Pull Request；
- 不再維護的套件，須先發 issue 尋找接手者。無人接手的，依據 [last rites](https://devmanual.gentoo.org/ebuild-maintenance/removal/) 流程移除：在 `profiles/package.mask` 最上方加入條目，寫明作者、電子郵件、日期（UTC）、原因和移除日期，至少 30 天後移除。範例：

  ```
  # Zakk <zakk@gentoozh.org> (2026-11-18)
  # Upstream archived.
  # Removal on 2026-12-18.
  net-proxy/daed
  ```

參考：

- [Devmanual](https://devmanual.gentoo.org/)
- [GLEP 66](https://www.gentoo.org/glep/glep-0066.html)：git 工作流程與提交訊息
- [GLEP 76](https://www.gentoo.org/glep/glep-0076.html)：著作權政策與 `Signed-off-by`
- [pkgdev](https://pkgcore.github.io/pkgdev/)、[pkgcheck](https://pkgcore.github.io/pkgcheck/)

## 提交

所有改動經 Pull Request 合併，禁止直接推送到 master 或繞過 CI。

提交遵循 [Gentoo git workflow](https://wiki.gentoo.org/wiki/Gentoo_git_workflow)：

- 首行為摘要，格式為 `category/package: 摘要`，不超過 69 個字元；
- 內文可選；如有內文，須與摘要行之間空一行；
- 須附 `Signed-off-by:`，可用 `pkgdev commit --signoff` 新增；
- 版本更新的格式為 `category/package: add 0.5, drop 0.4`；
- Pull Request 中不得有 merge commit，同步 master 時使用 `git rebase`，不使用 `git merge`。

範例：

```
app-misc/foo: fix build with GCC 16

Add a missing include.

Signed-off-by: A Developer <example@gentoo.org>
```

常用指令：

```
pkgdev manifest                  # 更新 Manifest
pkgcheck scan --net              # 檢查目前的改動
pkgdev commit --signoff          # 提交，產生摘要行並附 Signed-off-by
pkgdev commit --signoff -m "fix build with GCC 16" -m "Add a missing include."
                                 # 自訂摘要行和內文
pkgcheck scan --commits --net    # 發起 Pull Request 前檢查本分支的提交
```

> [!NOTE]
> `pkgdev commit` 的 `-b` 和 `-c` 會關聯到 bugs.gentoo.org，不要用於本儲存庫的 issue。

### Pull Request 描述

需按 Pull Request 範本填寫：

- 描述寫在 `<!-- Please put the pull request description above -->` 上方；
- 關閉本儲存庫的 issue 時，在描述中加入 `Closes #N`；
- 改動了套件、`eclass/`、`profiles/` 或 `licenses/` 時，須勾選 pkgcheck 對應項目；如果使用了 AI，須勾選 AI 聲明項目。

範例：

```
Because upstream 1.2.3 fixes a crash on Wayland, add it.

Closes #12345

<!-- Please put the pull request description above / 请把描述写在本行上方 -->

---

Do not delete this template, or the pull request will be rejected.
请勿删除本模板，否则 Pull Request 会被拒绝。

Please check all the boxes that apply:
请按情况勾选：

- [x] I have run `pkgcheck scan --commits --net` to check for issues with my commits.
  我已运行 `pkgcheck scan --commits --net` 检查本分支的提交。
- [x] If I used AI: I understand every change, tested it and take responsibility for it; commits with AI-written changes carry `Assisted-by:`.
  如果使用了 AI 辅助：我理解每一处改动，已经测试并对其负责，并且添加了 `Assisted-by:`。
```

> [!NOTE]
> 發起 Pull Request 後，須修復 pkgcheck 和 CI 回報的問題，包括 QA 警告。

## AI 政策

允許使用 AI，但須滿足以下要求：

- 使用 AI 輔助時須遵守 [AGENTS.md](./AGENTS.md)；
- 貢獻者須理解 AI 生成的內容；
- `Signed-off-by` 須由貢獻者本人新增，不得由工具新增；
- 新增 `Signed-off-by` 前，貢獻者須確認 AI 生成的部分沒有複製授權條款不相容的程式碼；
- AI 生成的提交訊息和 Pull Request 描述須準確、精簡、無冗餘，且所寫內容須經核實。

### 聲明

包含 AI 生成內容的提交，須在 `Signed-off-by:` 上方新增 `Assisted-by:` 行，格式遵循 [Linux 核心](https://docs.kernel.org/process/coding-assistants.html) 規範： `Assisted-by: 工具名:模型名`。用 `pkgdev commit -T` 新增：

```
pkgdev commit --signoff -m "fix build with GCC 16" -m "Add a missing include." -T Assisted-by:Claude:claude-opus-5-5
```

產生的提交訊息：

```
app-misc/foo: fix build with GCC 16

Add a missing include.

Assisted-by: Claude:claude-opus-5-5
Signed-off-by: A Developer <example@gentoo.org>
```

> [!NOTE]
> AI 協助不得以 `Co-authored-by:` 標註，否則 CI 會拒絕該提交。
> 人類共同作者可正常使用 `Co-authored-by:`。

以下情況無需聲明：

- 小改動或機械性改動；
- 僅使用 AI 審查自己的改動，並自行修復 AI 發現的問題。

### 禁止

- 在人類貢獻者沒有確認建置成功、通過測試和逐條審閱自動化工具產生的內容時，由自動化工具直接發起 Pull Request 或發表留言。
- 隱瞞或淡化 AI 的參與程度。

autobump、nvchecker 等本儲存庫自有的 bot 不受上述規則限制。

### 測試

AI 生成的改動與其他改動適用相同的測試要求，ebuild 須經過冒煙測試。不得虛報未實際進行的測試。

### 執行

如果懷疑貢獻中使用了 AI 卻未聲明，我們會要求說明，貢獻者須如實回答；拒絕說明的，我們會關閉該 Pull Request 或 issue。本規則同樣適用於維護者。

AI agent 可使用 [gentoo-zh/skills](https://github.com/gentoo-zh/skills) 進行打包、更新版本和程式碼審查。該工具集僅落實 AGENTS.md 的規範，不額外增設規則。安裝指令：

```
npx skills add gentoo-zh/skills -g
```

本節參考 [OpenWrt packages 的 AI 政策](https://github.com/openwrt/packages/blob/master/CONTRIBUTING.md#ai-policy)。
