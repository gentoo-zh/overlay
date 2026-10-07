# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

MY_PN="${PN%-bin}"

DESCRIPTION="A full-featured download manager"
HOMEPAGE="https://github.com/AnInsomniacy/rayburst"
URL_PREFIX="https://github.com/AnInsomniacy/rayburst/releases/download/v${PV}/Rayburst_${PV}"
SRC_URI="
	amd64? ( ${URL_PREFIX}_amd64.deb )
	arm64? ( ${URL_PREFIX}_arm64.deb )
"

S="${WORKDIR}"

LICENSE="MIT GPL-2+ LGPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RDEPEND="
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/pango
"

RESTRICT="strip"
QA_PREBUILT="usr/bin/aria2-next usr/bin/${MY_PN}*"

src_install() {
	dobin usr/bin/{aria2-next,${MY_PN},${MY_PN}-browser-launcher}

	insinto /usr/lib/Rayburst
	doins -r usr/lib/Rayburst/.

	domenu usr/share/applications/Rayburst.desktop

	for size in 32 128; do
		doicon -s ${size} usr/share/icons/hicolor/${size}x${size}/apps/${MY_PN}.png
	done
	doicon -s 256 usr/share/icons/hicolor/256x256@2/apps/${MY_PN}.png
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Motrix Next settings, tasks and history are not imported into Rayburst."
	elog "Finish active downloads before switching, then uninstall net-misc/motrix-next-bin."
}
