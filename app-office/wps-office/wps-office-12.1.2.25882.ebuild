# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

DESCRIPTION="WPS Office is an office productivity suite, Here is the Chinese version"
HOMEPAGE="https://www.wps.cn/product/wpslinux/"

SRC_URI="
	amd64?	( https://dogfood.gnupg.uk/wps302/${PV}/amd64 -> ${PN}_${PV}_amd64.deb )
"

S="${WORKDIR}"

LICENSE="WPS-EULA"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd"

RESTRICT="strip mirror bindist" # mirror as explained at bug #547372

# Deps are based on direct NEEDED entries from the 12.x core binaries, Qt plugins,
# and CEF libraries, excluding bundled libraries under office6.
RDEPEND="
	app-accessibility/at-spi2-core:2
	app-arch/bzip2:0
	app-arch/xz-utils
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	media-libs/libglvnd
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	sys-libs/glibc
	systemd? ( || ( sys-apps/systemd sys-apps/systemd-utils ) )
	virtual/zlib:0
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/libdrm
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libxcb
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libxkbcommon[X]
	x11-libs/pango
	loong? (
		virtual/loong-ow-compat
	)
"

pkg_nofetch() {
	einfo "Please download WPS Office 2019 For Linux version ${PV} from"
	einfo "    ${HOMEPAGE}"
	einfo "The archive should then be placed into your distfiles directory."
}

src_install() {
	exeinto /usr/bin
	exeopts -m0755
	doexe "${S}"/usr/bin/*

	insinto /usr/share
	doins -r "${S}"/usr/share/{applications,desktop-directories,icons,mime,templates}

	insinto /opt/kingsoft/wps-office
	use systemd || { rm "${S}"/opt/kingsoft/wps-office/office6/libdbus-1.so* || die ; }
	rm "${S}"/opt/kingsoft/wps-office/office6/libstdc++.so* || die
	doins -r "${S}"/opt/kingsoft/wps-office/{office6,templates}

	fperms 0755 /opt/kingsoft/wps-office/office6/{wps,wpp,et,wpspdf,wpsoffice,promecefpluginhost,transerr,ksolaunch,wpscloudsvr}
}
