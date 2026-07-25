# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="LXGW Bright: a Ming/serif-style Chinese font by LXGW"
HOMEPAGE="https://github.com/lxgw/LxgwBright"
SRC_URI="https://github.com/lxgw/LxgwBright/releases/download/v${PV}/LXGWBright.7z -> ${P}.7z"
S="${WORKDIR}/LXGWBright"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong ~riscv ~x86"

FONT_SUFFIX="ttf"

BDEPEND="app-arch/7zip"

src_unpack() {
	7z x "${DISTDIR}/${P}.7z" >/dev/null || die
}
