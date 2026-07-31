# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

DESCRIPTION="A truely minimal markdown editor"
HOMEPAGE="https://typora.io"
SRC_URI="https://download.typora.io/linux/typora_${PV}_amd64.deb"
S="${WORKDIR}"

LICENSE="typora"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="mirror splitdebug"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	virtual/libudev:=
	x11-libs/cairo
	x11-libs/gtk+:3[X]
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libxcb
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxkbcommon
	x11-libs/pango
"

QA_PREBUILT="*"

src_install() {
	mv "${S}/usr" "${D}" || die

	pushd "${D}/usr/share/doc" > /dev/null || die
	mv ${PN} ${P} || die
	popd > /dev/null || die
}
