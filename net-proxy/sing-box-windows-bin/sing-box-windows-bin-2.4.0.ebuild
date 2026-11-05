# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

MY_PN="${PN%-bin}"

DESCRIPTION="Modern sing-box desktop client"
HOMEPAGE="https://github.com/xinggaoya/sing-box-windows"
SRC_URI="amd64? (
	https://github.com/xinggaoya/sing-box-windows/releases/download/v${PV}/${MY_PN}_${PV}_amd64.deb
		-> ${P}_amd64.deb
)"

S="${WORKDIR}"

LICENSE="GPL-3+ MIT"
SLOT="0"
KEYWORDS="-* ~amd64"

RESTRICT="strip"

RDEPEND="
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	dev-libs/wayland
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
"

QA_PREBUILT="
	usr/bin/${MY_PN}
	usr/lib/${MY_PN}/kernel/linux/amd64/sing-box
"

src_install() {
	dobin "usr/bin/${MY_PN}"

	insinto "/usr/lib/${MY_PN}"
	doins -r "usr/lib/${MY_PN}/."
	fperms +x "/usr/lib/${MY_PN}/kernel/linux/amd64/sing-box"

	sed \
		-e 's|^Categories=.*|Categories=Network;|' \
		-e "s|^Comment=.*|Comment=${DESCRIPTION}|" \
		"usr/share/applications/${MY_PN}.desktop" \
		> "${T}/${MY_PN}.desktop" || die
	domenu "${T}/${MY_PN}.desktop"

	for size in 32 128; do
		doicon -s ${size} "usr/share/icons/hicolor/${size}x${size}/apps/${MY_PN}.png"
	done
	doicon -s 256 "usr/share/icons/hicolor/256x256@2/apps/${MY_PN}.png"
}
