# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg desktop wrapper

DESCRIPTION="BiliBili third-party client developed using Flutter"
HOMEPAGE="https://github.com/bggRGjQaUbCoE/PiliPlus"
MY_PV="2.1.6+5472"
SRC_URI="https://github.com/bggRGjQaUbCoE/PiliPlus/releases/download/${PV}/PiliPlus_linux_${MY_PV}_amd64.tar.gz"
S="${WORKDIR}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
QA_PREBUILT="*"
QA_DT_NEEDED="opt/${PN}/lib/libdartjni.so"
DEPEND="
	net-libs/webkit-gtk:4.1
	media-video/mpv[libmpv]
	x11-libs/libX11
	x11-libs/libXi
	x11-misc/xdg-user-dirs
"
RDEPEND="
	${DEPEND}
	app-accessibility/at-spi2-core:2
	dev-java/openjdk-jre-bin:*
	dev-libs/glib:2
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/harfbuzz
	media-libs/libepoxy
	net-libs/libsoup:3.0
	virtual/zlib
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/pango
"

src_install() {
	local instdir="/opt/${PN}"
	insinto "${instdir}"
	doins piliplus
	fperms +x "${instdir}/piliplus"
	doins -r data
	insinto "${instdir}/lib"
	doins lib/*.so
	make_wrapper "${PN}" "${instdir}/piliplus"
	domenu "${FILESDIR}/${PN}.desktop"
}
