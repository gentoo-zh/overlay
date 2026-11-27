# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

MY_PN="${PN%-bin}"

DESCRIPTION="A modern, feature-rich ebook reader"
HOMEPAGE="https://readest.com/ https://github.com/readest/readest"
URI_PREFIX="https://github.com/readest/readest/releases/download/v${PV}/Readest_${PV}"
SRC_URI="
	amd64? ( ${URI_PREFIX}_amd64.deb -> ${P}_amd64.deb )
	arm64? ( ${URI_PREFIX}_arm64.deb -> ${P}_arm64.deb )
"

S="${WORKDIR}"
LICENSE="AGPL-3"

SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RESTRICT="strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[opengl]
	net-print/cups
	sys-apps/dbus
	virtual/libudev
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-libs/pango
"

QA_PREBUILT="opt/${MY_PN}/*"

src_install() {
	insinto /opt/${MY_PN}
	doins -r usr/share/Readest/.
	fperms +x /opt/${MY_PN}/{${MY_PN},chrome-sandbox}
	dosym -r /opt/${MY_PN}/${MY_PN} /usr/bin/${MY_PN}

	domenu usr/share/applications/Readest.desktop
	local size
	for size in 32 128; do
		doicon -s ${size} usr/share/icons/hicolor/${size}x${size}/apps/${MY_PN}.png
	done
	doicon -s 256 usr/share/icons/hicolor/256x256@2/apps/${MY_PN}.png
}
