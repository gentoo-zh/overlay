# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker desktop xdg

DESCRIPTION="Z-library application"
HOMEPAGE="https://z-lib.fm/z-access"
URI_PREFIX="https://s3proxy-alp.cdn-zlib.sk/swfs_second_public_files/soft/desktop/Z-Library_"
SRC_URI="${URI_PREFIX}${PV}_amd64.deb"

S="${WORKDIR}"
LICENSE="all-rights-reserved"

SLOT="0"
KEYWORDS="-* ~amd64"

RESTRICT="bindist mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	virtual/zlib:=
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/pango
"

src_install() {
	insinto /opt/Z-Library
	doins -r "${S}"/opt/Z-Library/.
	fperms +x /opt/Z-Library/Z-Library
	fperms +x /opt/Z-Library/chrome-sandbox
	fperms +x /opt/Z-Library/chrome_crashpad_handler
	fperms +x /opt/Z-Library/resources/proxies/torProxy/linux-64/{tor,pluggable_transports/lyrebird}
	fperms +x /opt/Z-Library/resources/proxies/xray-proxy/xray/linux-64/xray

	domenu "${S}"/usr/share/applications/Z-Library.desktop

	for size in 16 32 48 64 128 256; do
		doicon -s ${size} "${S}"/usr/share/icons/hicolor/${size}x${size}/apps/Z-Library.png
	done
}
