# Copyright 2022-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="A Chinese serif font derived from IPAex Mincho and IPAmj Mincho"
HOMEPAGE="https://github.com/lxgw/LxgwNeoZhiSong"
SRC_URI="
	regular? (
		https://github.com/lxgw/LxgwNeoZhiSong/releases/download/v${PV}/LXGWNeoZhiSong.ttf -> ${P}.ttf
	)
	plus? (
		https://github.com/lxgw/LxgwNeoZhiSong/releases/download/v${PV}/LXGWNeoZhiSongPlus.ttf -> ${PN}-plus-${PV}.ttf
	)
"

S="${WORKDIR}"

LICENSE="IPAfont"
SLOT="0"
KEYWORDS="~amd64 ~loong ~riscv ~x86"

IUSE="+regular plus"
REQUIRED_USE="|| ( regular plus )"

FONT_SUFFIX="ttf"

src_unpack() {
	use regular && cp -v "${DISTDIR}/${P}.ttf" "LXGWNeoZhiSong.ttf"
	use plus && cp -v "${DISTDIR}/${PN}-plus-${PV}.ttf" "LXGWNeoZhiSongPlus.ttf"
}
