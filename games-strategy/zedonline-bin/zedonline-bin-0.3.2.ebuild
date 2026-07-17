# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop wrapper

DESCRIPTION="Online multiplayer remake of the 1996 RTS game Z"
HOMEPAGE="https://sourceforge.net/projects/zedonline/"
SRC_URI="https://downloads.sourceforge.net/zedonline/releases/ZED%20Online%20v${PV}%20Linux.zip"

S="${WORKDIR}"

LICENSE="GPL-3"

SLOT="0"
KEYWORDS="~amd64"

RESTRICT="strip"

QA_PREBUILT="
	opt/zedonline/ZED*
	opt/zedonline/libsciter-gtk.so
"

BDEPEND="
	app-arch/unzip
"
RDEPEND="
	media-libs/freetype:2
	net-misc/curl
	virtual/opengl
	x11-libs/gtk+:3
"

src_install() {
	insinto /opt/zedonline
	doins -r .
	fperms +x "/opt/zedonline/ZED Online"

	make_wrapper zed-online "'./ZED Online'" /opt/zedonline/

	domenu "${FILESDIR}/zedonline.desktop"
}

pkg_postinst() {
	einfo "See the game guide at https://zzone.lewe.com/commander-zod-single-player-guide"
}
