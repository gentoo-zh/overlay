# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Screen-reading optimized variant of LXGW WenKai"
HOMEPAGE="https://github.com/lxgw/LxgwWenKai-Screen"
SRC_BASE="https://github.com/lxgw/LxgwWenKai-Screen/releases/download/v${PV}"
SRC_URI="
	${SRC_BASE}/LXGWWenKaiScreen.ttf -> ${P}.ttf
	mono? ( ${SRC_BASE}/LXGWWenKaiMonoScreen.ttf -> ${PN}-mono-${PV}.ttf )
"
S="${WORKDIR}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong ~riscv ~x86"
IUSE="mono"

FONT_SUFFIX="ttf"

src_prepare() {
	default
	cp "${DISTDIR}"/${P}.ttf "${S}"/ || die
	if use mono ; then
		cp "${DISTDIR}"/${PN}-mono-${PV}.ttf "${S}"/ || die
	fi
}
