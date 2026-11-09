# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker desktop xdg

DESCRIPTION="Cross-platform IPTV player application with multiple features"
HOMEPAGE="https://4gray.github.io/iptvnator/"
SRC_URI="
	amd64? ( https://github.com/4gray/iptvnator/releases/download/v${PV}/iptvnator-${PV}-linux-amd64.deb )
	arm64? ( https://github.com/4gray/iptvnator/releases/download/v${PV}/iptvnator-${PV}-linux-arm64.deb )
"

S="${WORKDIR}"
LICENSE="MIT"

SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RESTRICT="strip"

QA_PREBUILT="opt/IPTVnator/*"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/libglvnd
	media-libs/mesa[gbm(+)]
	media-video/mpv:0[libmpv]
	net-print/cups
	sys-apps/dbus
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3[X,cups]
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

src_prepare() {
	default

	local prebuilds="${S}/opt/IPTVnator/resources/app.asar.unpacked/node_modules/better-sqlite3/prebuilds"
	case ${ARCH} in
		amd64) rm "${prebuilds}"/linux-arm64.node || die ;;
		arm64) rm "${prebuilds}"/linux-x64.node || die ;;
	esac
	rm "${prebuilds}"/linuxmusl-{arm64,x64}.node || die

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

	for size in 16 24 32 48 64 128 256; do
		doicon -s ${size} "${S}"/usr/share/icons/hicolor/${size}x${size}/apps/iptvnator.png
	done
}
