<div align="right">

[English](./README.en.md) | [简体中文](./README.md) | [正體中文](./README.zh-TW.md) | 廣東話

</div>

# gentoo-zh

Overlay for Gentoo Users.\
gentoo-zh 係一個包容嘅 overlay。

> [!NOTE]
> gentoo-zh overlay 已經搬咗去 https://github.com/gentoo-zh/overlay 。舊嘅 GitHub URL 會繼續重新導向。如果你手動設定過 remote，得閒改返佢就得。
> 詳情請睇 [MIGRATION.md](./MIGRATION.md)。

## 社群

[![官網](https://img.shields.io/badge/%E5%AE%98%E7%B6%B2-gentoozh.org-54487A?logo=gentoo&logoColor=white)](https://gentoozh.org/zh-tw/)
[![GitHub Issues](https://img.shields.io/badge/GitHub-Issues-181717?logo=github)](https://github.com/gentoo-zh/overlay/issues)
[![Email](https://img.shields.io/badge/Email-overlay%40gentoozh.org-000000?logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjZmZmIiBzdHJva2Utd2lkdGg9IjIiPjxyZWN0IHg9IjIiIHk9IjQiIHdpZHRoPSIyMCIgaGVpZ2h0PSIxNiIvPjxwYXRoIGQ9Im0yIDYgMTAgNyAxMC03Ii8%2BPC9zdmc%2B)](mailto:overlay@gentoozh.org)
[![論壇](https://img.shields.io/badge/%E8%AB%96%E5%A3%87-forum.gentoozh.org-54487A?logo=discourse&logoColor=white)](https://forum.gentoozh.org/)
[![維基](https://img.shields.io/badge/%E7%B6%AD%E5%9F%BA-Gentoo--zh-54487A?logo=gentoo&logoColor=white)](https://wiki.gentoo.org/wiki/Gentoo-zh)
[![Telegram 群組](https://img.shields.io/badge/%E7%BE%A4%E7%B5%84-gentoo__zh-26A5E4?logo=telegram&logoColor=white)](https://t.me/gentoo_zh)
[![公告頻道](https://img.shields.io/badge/%E5%85%AC%E5%91%8A-gentoocn-26A5E4?logo=telegram&logoColor=white)](https://t.me/gentoocn)
[![Matrix](https://img.shields.io/badge/Matrix-%23gentoo--zh-000000?logo=matrix&logoColor=white)](https://matrix.to/#/%23gentoo-zh:matrix.gentoozh.org)
[![IRC](https://img.shields.io/badge/IRC-%23gentoo--zh-000000?logo=liberadotchat&logoColor=white)](https://web.libera.chat/#gentoo-zh)

overlay 相關問題優先使用 GitHub Issues。

## 點樣將呢個 overlay 加入 Gentoo Linux

```
eselect repository enable gentoo-zh
emaint sync
```

中國大陸鏡像加速相關同 overlay 點樣用請睇：https://gentoozh.org/zh-tw/overlay

## distfiles 同二進制軟件包

部分軟件包有 distfiles 同二進制軟件包，每晚觸發構建，設定同鏡像請睇：https://distfiles.gentoozh.org

## 依賴關係表

https://github.com/gentoo-zh/overlay/blob/deps-table/relation.md

## 貢獻

**唔好整爛人哋個系統。**

* 我哋歡迎所有人貢獻，不過請提交者喺提交之前小心確認清楚。
* pull request 入面每個提交都要包含所需嘅全部修改，唔好無故拆開，例如 ebuild 同佢個 `Manifest` 要擺喺同一個提交入面。
* 每個 ebuild 改動喺提交之前要確保編譯得到。
* `LICENSE` 要同上游實際授權一致。授權唔喺 `::gentoo` 嘅時候，將全文放入 [`licenses/`](./licenses)，歸入 [`profiles/license_groups`](./profiles/license_groups) 嘅相應分組，並按佢嘅散布條款設定 `RESTRICT`。
* 新加嘅軟件包要加入 [`.github/workflows/overlay.toml`](./.github/workflows/overlay.toml)，按 `category/package` 嘅字母順序擺入對應位置。如果可以自動 bump，請睇 [scripts/autobump.zh.md](./scripts/autobump.zh.md)。
* 如果軟件包唔適合用 nvchecker 檢查版本更新，就喺對應位置加返個註釋講清楚點解。當多個 nvchecker 條目指向同一個來源，亦請註釋其中一個；如果嗰個包可以啟用 autobump 就可以例外。
* 開 pull request 之前，請先喺本地跑 `pkgcheck scan --commits --net`。
* 開 pull request 之後，請檢查同修正 pkgcheck report 同 CI 報出嘅錯誤，QA 提示都要處理。
* ebuild 淨係用 `~arch` keyword，唔用 stable keyword。
* CI 會喺 amd64 同 arm64 上面構建。如果喺你冇嘅架構上面出現解決唔到嘅問題，就移除嗰個 keyword。
* 自己加嘅軟件包請一直維護落去，並且用 [pull request 範本](./.github/pull_request_template.md)。
* 唔再維護自己嘅軟件包嗰陣，請喺 issues 度搵新維護者，或者喺 [`profiles/package.mask`](./profiles/package.mask) 度 mask，到期之後再移除。

### 提交訊息

建議用 `pkgdev commit` 產生提交訊息。版本升級格式如下：

```
$category/$package: add $new_version, drop $old_version
```

其他改動格式如下：

```
$category/$package: one line short description message

multiple lines of description about why you change this.
if you change to fix the bug, and if there is an GitHub
issue entry for that bug, then point the bug link here.
```

## AI 政策

可以用生成式 AI 輔助，不過佢必須遵守 [AGENTS.md](./AGENTS.md)，而且每個提交由貢獻者負責：確保 ebuild 嘅質素同驗證功能正確，ebuild 要實際做一次冒煙測試先好提交，pull request 描述要簡短、精準、專業，寫實測結果而唔係靠估。貢獻者、提交者同提交作者必須係真人，唔可以係 AI 工具或者模型身份。
