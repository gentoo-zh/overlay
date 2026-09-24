# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker desktop xdg

DESCRIPTION="Open source API development ecosystem"
HOMEPAGE="https://hoppscotch.io"
MY_PV=$(ver_rs 3 '-')
SRC_URI="https://github.com/hoppscotch/releases/releases/download/v${MY_PV}/Hoppscotch_linux_x64.deb -> ${P}.deb"

S="${WORKDIR}"
LICENSE="MIT"

SLOT="0"
KEYWORDS="~amd64"

RDEPEND="net-libs/webkit-gtk:4.1"

RESTRICT="strip"

src_install() {
	dobin "${S}"/usr/bin/hoppscotch-desktop

	domenu "${S}"/usr/share/applications/Hoppscotch.desktop

	for size in 32 128; do
		doicon -s ${size} "${S}"/usr/share/icons/hicolor/${size}x${size}/apps/hoppscotch-desktop.png
	done
	doicon -s 256 "${S}"/usr/share/icons/hicolor/256x256@2/apps/hoppscotch-desktop.png
}
