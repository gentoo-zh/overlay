# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="A Simplified Chinese sans-serif font derived from IPAex Gothic"
HOMEPAGE="https://github.com/lxgw/LxgwNeoXiHei"
SRC_URI="
	regular? ( https://github.com/lxgw/LxgwNeoXiHei/releases/download/v${PV}/LXGWNeoXiHei.ttf -> ${P}.ttf )
	plus? ( https://github.com/lxgw/LxgwNeoXiHei/releases/download/v${PV}/LXGWNeoXiHeiPlus.ttf -> ${PN}-plus-${PV}.ttf )
"

S="${WORKDIR}"

LICENSE="IPAfont"
SLOT="0"
KEYWORDS="~amd64 ~loong ~riscv ~x86"

IUSE="+regular plus"
REQUIRED_USE="|| ( regular plus )"

FONT_SUFFIX="ttf"

src_unpack() {
	use regular && cp -v "${DISTDIR}/${P}.ttf" "LXGWNeoXiHei.ttf"
	use plus && cp -v "${DISTDIR}/${PN}-plus-${PV}.ttf" "LXGWNeoXiHeiPlus.ttf"
}
