# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

DESCRIPTION="A notebook based on p2p network"
HOMEPAGE="https://anytype.io"
SRC_URI="https://github.com/anyproto/anytype-ts/releases/download/v${PV}/anytype_${PV}_amd64.deb"

S="${WORKDIR}"
LICENSE="ASAL-1.0"
SLOT="0"
KEYWORDS="-* ~amd64"

RESTRICT="bindist mirror strip"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
"

QA_PREBUILT="opt/Anytype/*"

src_install() {
	mkdir -p "${ED}"/opt || die
	cp -a opt/Anytype "${ED}"/opt/ || die
	dosym -r /opt/Anytype/anytype /usr/bin/anytype

	insinto /usr/share
	doins -r usr/share/applications usr/share/icons
}
