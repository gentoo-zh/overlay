# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Kose Font (小赖字体) - An open-source Chinese font"
HOMEPAGE="https://github.com/lxgw/kose-font"
SRC_URI="
	regular? ( https://github.com/lxgw/kose-font/releases/download/v${PV}/Xiaolai-Regular.ttf -> ${P}.ttf )
	mono? ( https://github.com/lxgw/kose-font/releases/download/v${PV}/XiaolaiMono-Regular.ttf -> ${PN}-mono-${PV}.ttf )
"

S="${WORKDIR}"
LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong ~riscv ~x86"

IUSE="+regular mono"

FONT_SUFFIX="ttf"

src_unpack() {
	use regular && cp -v "${DISTDIR}/${P}.ttf" "Xiaolai-Regular.ttf"
	use mono && cp -v "${DISTDIR}/${PN}-mono-${PV}.ttf" "XiaolaiMono-Regular.ttf"
}
