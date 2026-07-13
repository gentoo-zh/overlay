# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker desktop xdg

DESCRIPTION="Opensource IDE For Exploring and Testing Api's"
HOMEPAGE="https://www.usebruno.com/"
SRC_URI="https://github.com/usebruno/bruno/releases/download/v${PV}/bruno_${PV}_amd64_linux.deb"

S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64"

RDEPEND="
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	x11-libs/gtk+:3[X,cups]
	x11-libs/libxkbcommon[X]
"

RESTRICT="strip"

src_install() {
	insinto /opt/Bruno
	doins -r "${S}"/opt/Bruno/.
	fperms +x /opt/Bruno/bruno
	fperms +x /opt/Bruno/chrome-sandbox
	fperms +x /opt/Bruno/chrome_crashpad_handler

	domenu "${S}"/usr/share/applications/bruno.desktop

	for size in 16 24 32 48 64 128 256 512 1024; do
		doicon -s ${size} "${S}"/usr/share/icons/hicolor/${size}x${size}/apps/bruno.png
	done
}
