<div align="right">

[English](./README.md) | [简体中文](./README.zh-CN.md) | 正體中文

</div>

# gentoo-zh

Overlay for Gentoo Users.\
gentoo-zh 是一個包容的 overlay。

> [!NOTE]
> gentoo-zh overlay 已遷移至 https://github.com/gentoo-zh/overlay 。舊的 GitHub URL 會繼續重新導向。如果你手動設定過 remote，可於方便時更新。
> 詳情請參閱 [MIGRATION.md](./MIGRATION.md)。

## 社群

[![官網](https://img.shields.io/badge/%E5%AE%98%E7%B6%B2-gentoozh.org-54487A?logo=gentoo&logoColor=white)](https://gentoozh.org/zh-tw/)
[![GitHub Issues](https://img.shields.io/badge/GitHub-Issues-181717?logo=github)](https://github.com/gentoo-zh/overlay/issues)
[![Email](https://img.shields.io/badge/Email-overlay%40gentoozh.org-EA4335?logo=maildotcom&logoColor=white)](mailto:overlay@gentoozh.org)
[![論壇](https://img.shields.io/badge/%E8%AB%96%E5%A3%87-forum.gentoozh.org-000000?logo=discourse&logoColor=white)](https://forum.gentoozh.org/)
[![維基](https://img.shields.io/badge/%E7%B6%AD%E5%9F%BA-Gentoo--zh-54487A?logo=gentoo&logoColor=white)](https://wiki.gentoo.org/wiki/Gentoo-zh)
[![Telegram 群組](https://img.shields.io/badge/%E7%BE%A4%E7%B5%84-gentoo__zh-26A5E4?logo=telegram&logoColor=white)](https://t.me/gentoo_zh)
[![公告頻道](https://img.shields.io/badge/%E5%85%AC%E5%91%8A-gentoocn-26A5E4?logo=telegram&logoColor=white)](https://t.me/gentoocn)
[![Matrix](https://img.shields.io/badge/Matrix-%23gentoo--zh-000000?logo=matrix&logoColor=white)](https://matrix.to/#/%23gentoo-zh:matrix.gentoozh.org)
[![IRC](https://img.shields.io/badge/IRC-%23gentoo--zh-5A5A5A?logo=liberadotchat&logoColor=white)](https://web.libera.chat/#gentoo-zh)

overlay 的問題優先走 GitHub Issues。

## 如何將此 overlay 加入 Gentoo Linux

```
eselect repository enable gentoo-zh
emaint sync
```

中國大陸鏡像加速相關請參考：https://gentoozh.org/zh-tw/overlay/

## distfiles 與二進位套件

部分套件提供 distfiles 與二進位套件，每晚觸發建置，設定和鏡像參考：https://distfiles.gentoozh.org

## 相依關係表

https://github.com/gentoo-zh/overlay/blob/deps-table/relation.md

## 貢獻

**不要破壞使用者的系統。**

* 我們歡迎所有人貢獻，但請提交者在提交前謹慎確認。
* PR 中的每個提交都要包含所需的所有修改，不要無故拆分，例如 ebuild 和它的 `Manifest` 要在同一個提交裡。
* 每個 ebuild 修改在提交前要確保編譯正確。
* 新增的套件需要加入 [`.github/workflows/overlay.toml`](./.github/workflows/overlay.toml)，並按照 `category/package` 的字母順序插入相應位置；如果該套件不適合使用 nvchecker 檢查版本更新，請在對應位置加上註解並說明原因；如果可以自動 bump，參見 [scripts/autobump.zh.md](./scripts/autobump.zh.md)。
* 在開啟 pull request 前，請先在本機執行 `pkgcheck scan --commits --net`。
* 開 pull request 之後，請檢查並修正 pkgcheck report 和 CI 報出的錯誤，QA 提示也要處理。
* CI 會在 amd64 和 arm64 上建置。如果在你沒有的架構上出現無法解決的問題，請移除那個 keyword。
* 新增的套件請持續維護，並使用 [pull request 範本](./.github/pull_request_template.md)。
* 不再維護自己的套件時，請在 issues 裡找新維護者，或者在 [`profiles/package.mask`](./profiles/package.mask) 裡 mask，到期後再移除。

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

可以用生成式 AI 輔助，但它必須遵守 [AGENTS.md](./AGENTS.md)，且每個提交由貢獻者負責：確保 ebuild 的品質和驗證功能正確，ebuild 要實際做一遍冒煙測試再提交，pull request 描述要簡短、精準、專業，寫實測結果而不是猜測。貢獻者、提交者與提交作者必須是人類，不能是 AI 工具或模型身分。
