[English](./README.md) | [简体中文](./README.zh-CN.md) | 正體中文

> [!NOTE]
> gentoo-zh overlay 已遷移至 https://github.com/gentoo-zh/overlay 。舊的 GitHub URL 會繼續重新導向。如果你手動設定過 remote，可於方便時更新。

## 倉庫遷移

本倉庫透過 GitHub repository transfer 從 `microcai/gentoo-zh` 轉移到 `gentoo-zh` 組織，隨後又重新命名為 `gentoo-zh/overlay`。

目前倉庫位址：

https://github.com/gentoo-zh/overlay

詳情請參閱 [MIGRATION.md](./MIGRATION.md)。

# 如何將此 overlay 加入 Gentoo 系統

```
eselect repository enable gentoo-zh
emaint sync
```

# 規則一

不要破壞使用者的系統。

# 規則二

不要破壞使用者的系統。

# 規則三

遵守規則一與規則二。

# 相依關係表

https://github.com/gentoo-zh/overlay/blob/deps-table/relation.md

# 提交訊息

建議使用 `pkgdev commit` 快速產生提交訊息。

* 對於非版本升級的提交，提交訊息格式應類似：

        $category/$package: one line short description message
        {empty line}
        multiple lines of description about why you change this.
        if you change to fix the bug, and if there is an GitHub
        issue entry for that bug, then point the bug link here.

* 對於版本升級的提交，提交訊息格式應類似：

        $category/$package: add $new_version, drop $old_version

# 貢獻

* 我信任擁有提交權限的貢獻者，因此提交者在提交前應謹慎確認。

* 可以使用生成式 AI 輔助 ebuild 維護，但貢獻者必須確保相關 ebuild
  修改的品質。尤其要在修改後驗證功能正確性；包括 CLI、GUI 等應用型態在內的應用，
  都應在提交前進行適當的冒煙測試。即使使用生成式 AI 輔助維護，貢獻者仍然是每個提交的第一責任人。
  貢獻者、提交者與提交作者必須是人類，不能是 Codex、GPT、Claude、Gemini 等 AI 工具或模型身分，
  也不能是類似系統。

* 如果你要發起新的 pull request，請確保其中包含單個貢獻所需的所有提交，
  例如不要把一個 ebuild 和它的 `Manifest` 拆成兩個 pull request。

* 每個 ebuild 修改在提交前都不應導致編譯錯誤。

* 每個 ebuild 都應在其 `KEYWORDS` 宣告的每個 ARCH 上測試。
  如果沒有測試，就不要聲稱支援該 keyword。

* 每個 ebuild 都應使用 ~arch keywords，不得使用 stable keywords。

* 在開啟 pull request 前，請先在本機執行 `pkgcheck scan --commits --net`。

# Distfiles 鏡像

我們提供 distfiles 鏡像，用於快取 gentoo-zh 的 distfiles。

我們的伺服器託管在美國：
```
GENTOO_MIRRORS="${GENTOO_MIRRORS} https://distfiles.gentoozh.org"
```

重慶大學鏡像：
```
GENTOO_MIRRORS="${GENTOO_MIRRORS} https://mirrors.cqu.edu.cn/gentoo-zh"
```

南京大學鏡像：
```
GENTOO_MIRRORS="${GENTOO_MIRRORS} https://mirrors.nju.edu.cn/gentoo-zh"
```
