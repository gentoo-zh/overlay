# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

MY_PN="MiSans_Global_ALL"

DESCRIPTION="MiSans 是由小米主导,联合汉仪发布的可免费使用的字体"
HOMEPAGE="https://hyperos.mi.com/font"
SRC_URI="https://hyperos.mi.com/font-download/${MY_PN}.zip -> ${P}.zip"
S="${WORKDIR}/MiSans Global _ALL"

LICENSE="MiSans"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
BDEPEND="app-arch/unzip"
FONT_SUFFIX="otf ttf"

RESTRICT="bindist mirror"

src_unpack() {
	unpack "${A}"

	cd "$S"
	local MY_FONTS=(
		"MiSans.zip"
		"MiSana Arabic.zip"
		"MiSans Gurmukhi.zip"
		" MiSans Lao.zip"
		"MiSans TC.zip"
		"MiSans Devanagari.zip"
		"MiSans Khmer.zip"
		"MiSans Latin.zip"
		"MiSans Thai .zip"
		"MiSans Gujarati.zip"
		"MiSans L3.zip"
		"MiSans Myanmar.zip"
		"MiSans Tibetan.zip"
	)

	for name in "${MY_FONTS[@]}"; do
		unpack "./${name}"
	done
}

src_install() {
	find . \( -iname '*.otf' -o -iname '*.ttf' \) -exec cp "{}" . \; || die
	font_src_install

	insinto /etc/fonts/conf.avail
	doins "${FILESDIR}/70-mi-sans-cjk.conf"
	doins "${FILESDIR}/71-mi-sans-default.conf"
}
