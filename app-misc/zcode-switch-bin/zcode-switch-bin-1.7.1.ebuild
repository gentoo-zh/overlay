# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

MY_PN="${PN%-bin}"
DESCRIPTION="One-click switcher for multiple ZCode accounts with quota display"
HOMEPAGE="https://github.com/pjpv/zcode-switch"
SRC_URI="
	amd64? ( https://github.com/pjpv/zcode-switch/releases/download/v${PV}/${MY_PN}_${PV}_amd64.deb )
"
S="${WORKDIR}"

LICENSE="
	Apache-2.0 BSD ISC MIT MPL-2.0 Unicode-3.0 openssl
"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

RDEPEND="
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-misc/xdg-utils
"

QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	dobin usr/bin/${MY_PN}

	local size
	for size in 32 128 512; do
		doicon -s ${size} usr/share/icons/hicolor/${size}x${size}/apps/${MY_PN}.png
	done
	doicon -s 256 usr/share/icons/hicolor/256x256@2/apps/${MY_PN}.png

	make_desktop_entry --eapi9 "${MY_PN}" -n "Z·SWITCH" -i "${MY_PN}" \
		-c "Utility;" -e "StartupWMClass=${MY_PN}" -e "Terminal=false"
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "Use Portage to update zcode-switch; do not use its built-in updater."
}
