# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Apply SteamGridDB assets directly to your Steam library"
HOMEPAGE="https://github.com/SteamGridDB/SGDBoop https://www.steamgriddb.com/boop"
SRC_URI="https://github.com/SteamGridDB/SGDBoop/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/SGDBoop-${PV}"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

PATCHES=(
	"${FILESDIR}/sgdboop-1.4.3-cflags.patch"
)

RDEPEND="
	net-misc/curl:=[ssl]
	x11-libs/gtk+:3
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
"

src_install() {
	dobin SGDBoop

	domenu res/linux/com.steamgriddb.SGDBoop.desktop
	doicon -s scalable res/com.steamgriddb.SGDBoop.svg

	insinto /usr/share/metainfo
	doins com.steamgriddb.SGDBoop.appdata.xml
}
