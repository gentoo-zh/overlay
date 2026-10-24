# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.2-gtk3"
inherit autotools git-r3 wxwidgets

DESCRIPTION="$PN, dynamic DLP library for amule-dlp"
HOMEPAGE="https://github.com/persmule/amule-dlp.antileech"
EGIT_REPO_URI="https://github.com/persmule/amule-dlp.antiLeech.git"

LICENSE="GPL-2+"
SLOT="0"
IUSE="X"

DEPEND="x11-libs/wxGTK:${WX_GTK_VER}[X?]"
RDEPEND="net-p2p/amule-dlp"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	setup-wxwidgets
	econf
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
