<div align="right">

[English](./CONTRIBUTING.en.md) | [简体中文](./CONTRIBUTING.md) | 正體中文

</div>

# 貢獻指南

gentoo-zh 是 Gentoo 的 overlay（第三方 ebuild 儲存庫），不獨立於 Gentoo。

> [!NOTE]
> 故意繞過本文規定者將被移出組織，其維護的全部套件將被 treeclean。此規則適用於全部維護者，包括 owner 和 member。

## 套件

- ebuild 只使用 `~arch` 關鍵字；
- 每個套件須有 `metadata.xml`，並寫明維護者；
- `LICENSE` 須與所打包軟體聲明的授權條款一致，`::gentoo` 沒有的授權條款須加入 `licenses/` 和 `profiles/license_groups`；
- 除特殊情況外，同一套件的改動須在同一個提交中；
- 套件須登記到 `.github/workflows/overlay.toml`，依 `category/package` 的字母順序插入，不適合 nvchecker 的須註解原因；
- 可自動更新版本的套件見 [scripts/autobump.zh.md](./scripts/autobump.zh.md)；
- ebuild 提交前須進行測試；
- 不再維護的套件，須在 issue 中尋找接手者。無人接手的，依據 [last rites](https://devmanual.gentoo.org/ebuild-maintenance/removal/) 流程移除：在 `profiles/package.mask` 最上方加入條目，寫明作者、電子郵件、日期（UTC）、原因和移除日期，至少 30 天後移除。範例：

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

所有改動經 pull request 合併，禁止直接推送 master 或繞過 CI。

提交遵循 [Gentoo git workflow](https://wiki.gentoo.org/wiki/Gentoo_git_workflow)：

- 第一行為摘要行，格式為 `category/package: 摘要`，不超過 69 個字元；
- 內文可選；如有內文，須與摘要行之間空一行；
- 須附 `Signed-off-by:`，可用 `pkgdev commit --signoff` 新增；
- 版本更新的格式為 `category/package: add 0.5, drop 0.4`；
- pull request 中不得有 merge commit，同步 master 時使用 `git rebase`，不使用 `git merge`。

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
pkgcheck scan --commits --net    # 發起 pull request 前檢查本分支的提交
```

> [!NOTE]
> `pkgdev commit` 的 `-b` 和 `-c` 會引用到 bugs.gentoo.org，不要用於本儲存庫的 issue。

### pull request 描述

須使用 pull request 範本：

- 描述寫在 `<!-- Please put the pull request description above -->` 之上；
- 關閉本儲存庫的 issue 時，在描述中加入 `Closes #N`；
- 改動了套件、`eclass/`、`profiles/` 或 `licenses/` 時，須勾選 pkgcheck；如果使用了 AI，須勾選 AI。

範例：

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
> 發起 pull request 後，須修復 pkgcheck 報告和 CI 發現的問題，包括 QA 提示。

## AI 政策

允許使用 AI，但須滿足以下要求：

- 使用 AI 輔助時須遵守 [AGENTS.md](./AGENTS.md)；
- 貢獻者須理解 AI 生成的內容；
- `Signed-off-by` 須由貢獻者本人新增，不得由工具新增；
- 新增 `Signed-off-by` 前，貢獻者須確認 AI 生成的部分沒有複製授權條款不相容的程式碼；
- AI 生成的提交訊息和 pull request 描述須準確、精簡、不重複，所述內容須經驗證。

### 聲明

含 AI 生成改動的提交，須在 `Signed-off-by:` 之上新增 `Assisted-by:` 行，格式同 [Linux 核心](https://docs.kernel.org/process/coding-assistants.html)，為 `Assisted-by: 工具名:模型名`。用 `pkgdev commit -T` 新增：

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
> 不得使用 `Co-authored-by:`，CI 將拒絕。

以下情況無需聲明：

- 小改動或機械性改動；
- 僅使用 AI 審查貢獻者自己的改動，並由貢獻者自行修復 AI 發現的問題。

### 禁止

- 未經貢獻者逐條閱讀並批准，即由工具發出的 pull request、推送或留言。
- 根據工具輸出批次發起 pull request，且未逐一建置、測試。
- 隱瞞或淡化 AI 的參與程度。

autobump、nvchecker 等本儲存庫自有的 bot 不受上述規則限制。

### 測試

AI 生成的改動與其他改動適用相同的測試要求，ebuild 須經過冒煙測試。不得聲稱執行了實際未執行的測試。

### 執行

如果懷疑貢獻中使用了 AI 卻未聲明，我們會要求說明，貢獻者須如實回答；拒絕說明的，我們會關閉該 pull request 或 issue。本規則同樣適用於維護者。

agent 可以使用 [gentoo-zh/skills](https://github.com/gentoo-zh/skills) 打包、更新版本和審查。它只執行 AGENTS.md 的規則，不另立規則。安裝指令：

```
npx skills add gentoo-zh/skills -g
```

本節參考 [OpenWrt packages 的 AI 政策](https://github.com/openwrt/packages/blob/master/CONTRIBUTING.md#ai-policy)。
