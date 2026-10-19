# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Fcitx5 自建拼音输入法词库，百万常用词汇量。"
HOMEPAGE="https://github.com/wuhgit/CustomPinyinDictionary"
SRC_URI="
	https://github.com/wuhgit/CustomPinyinDictionary/releases/download/assets/CustomPinyinDictionary_Fcitx.dict
		-> ${P}.dict
"

S="${DISTDIR}"

LICENSE="|| ( CC-BY-SA-4.0 FDL-1.3 )"
SLOT="5"
KEYWORDS="~amd64 ~arm64"
IUSE="+fcitx rime"
REQUIRED_USE="|| ( fcitx rime )"

RDEPEND="
	fcitx? ( app-i18n/fcitx:5 )
	rime? ( || ( app-i18n/ibus-rime app-i18n/fcitx-rime ) )
"
BDEPEND="rime? ( app-i18n/libime:5 )"

src_compile() {
	if use rime; then
		libime_pinyindict -d "${P}.dict" CustomPinyinDictionary_Rime.raw
		printf -- '---\nname: CustomPinyinDictionary\nversion: "0.1"\nsort: by_weight\n...\n' \
			> CustomPinyinDictionary_Rime.dict.yaml
		cat CustomPinyinDictionary_Rime.raw >> CustomPinyinDictionary_Rime.dict.yaml
	fi
}

src_install() {
	if use fcitx; then
		DICT_PATH="/usr/share/fcitx5/pinyin/dictionaries"
		insinto "${DICT_PATH}"
		doins "${P}.dict"
		fperms 0644 "${DICT_PATH}/${P}.dict"
	fi

	if use rime; then
		DICT_PATH="/usr/share/rime-data"
		insinto "${DICT_PATH}"
		doins CustomPinyinDictionary_Rime.dict.yaml
		fperms 0644 "${DICT_PATH}/CustomPinyinDictionary_Rime.dict.yaml"
	fi
}
