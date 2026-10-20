# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Yozai Font (悠哉字体) - A Chinese font derived from Y.OzFont"
HOMEPAGE="https://github.com/lxgw/yozai-font"
SRC_URI="
	light? ( https://github.com/lxgw/yozai-font/releases/download/v${PV}/Yozai-Light.ttf -> ${PN}-light-${PV}.ttf )
	regular? ( https://github.com/lxgw/yozai-font/releases/download/v${PV}/Yozai-Regular.ttf -> ${P}.ttf )
	medium? ( https://github.com/lxgw/yozai-font/releases/download/v${PV}/Yozai-Medium.ttf -> ${PN}-medium-${PV}.ttf )
"

S="${WORKDIR}"
LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong ~riscv ~x86"

IUSE="light +regular medium"

FONT_SUFFIX="ttf"

src_unpack() {
	use light && cp -v "${DISTDIR}/${PN}-light-${PV}.ttf" "Yozai-Light.ttf"
	use regular && cp -v "${DISTDIR}/${P}.ttf" "Yozai-Regular.ttf"
	use medium && cp -v "${DISTDIR}/${PN}-medium-${PV}.ttf" "Yozai-Medium.ttf"
}
