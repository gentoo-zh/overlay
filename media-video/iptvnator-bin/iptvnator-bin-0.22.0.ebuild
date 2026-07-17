# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker desktop xdg

DESCRIPTION="Cross-platform IPTV player application with multiple features"
HOMEPAGE="https://4gray.github.io/iptvnator/"
SRC_URI="https://github.com/4gray/iptvnator/releases/download/v${PV}/iptvnator-${PV}-linux-amd64.deb"

S="${WORKDIR}"
LICENSE="MIT"

SLOT="0"
KEYWORDS="~amd64"

RESTRICT="strip"

RDEPEND="
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	x11-libs/gtk+:3[X,cups]
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libxcb
	x11-libs/libxkbcommon
"

src_prepare() {
	default

	sed -i 's/Categories=Video;/Categories=AudioVideo;Video;/' "${S}"/usr/share/applications/iptvnator.desktop
}

src_install() {
	insinto /opt/IPTVnator
	doins -r "${S}"/opt/IPTVnator/.
	fperms +x /opt/IPTVnator/iptvnator
	fperms +x /opt/IPTVnator/iptvnator.bin
	fperms +x /opt/IPTVnator/chrome-sandbox
	fperms +x /opt/IPTVnator/chrome_crashpad_handler

	domenu "${S}"/usr/share/applications/iptvnator.desktop

	for size in 192 512; do
		doicon -s ${size} "${S}"/usr/share/icons/hicolor/${size}x${size}/apps/iptvnator.png
	done
}
