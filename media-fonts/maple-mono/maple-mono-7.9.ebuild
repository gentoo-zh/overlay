# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Maple Mono: an open-source monospace font with ligatures and CJK support"
HOMEPAGE="https://github.com/subframe7536/maple-font"
SRC_URI="
	cjk? (
		nerdfont? (
			https://github.com/subframe7536/maple-font/releases/download/v${PV}/MapleMono-NF-CN.zip
				-> ${P}-nf-cn.zip
		)
		!nerdfont? (
			https://github.com/subframe7536/maple-font/releases/download/v${PV}/MapleMono-CN.zip
				-> ${P}-cn.zip
		)
	)
	!cjk? (
		nerdfont? (
			https://github.com/subframe7536/maple-font/releases/download/v${PV}/MapleMono-NF.zip
				-> ${P}-nf.zip
		)
		!nerdfont? (
			https://github.com/subframe7536/maple-font/releases/download/v${PV}/MapleMono-TTF.zip
				-> ${P}.zip
		)
	)
"
S="${WORKDIR}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong ~riscv ~x86"
IUSE="+cjk +nerdfont"

FONT_SUFFIX="ttf"

BDEPEND="app-arch/unzip"
