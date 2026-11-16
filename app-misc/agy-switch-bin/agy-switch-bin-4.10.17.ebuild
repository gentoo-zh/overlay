# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

MY_PN="${PN%-bin}"

DESCRIPTION="Local Antigravity account switching and usage dashboard"
HOMEPAGE="https://github.com/anglee0323/agy-switch"
SRC_URI="
	amd64? ( https://github.com/anglee0323/agy-switch/releases/download/v${PV}/${MY_PN}-${PV}-linux-amd64.deb )
"
S="${WORKDIR}"

LICENSE="
	0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD CC-BY-NC-SA-4.0
	CDLA-Permissive-2.0 GPL-3 ISC MIT MPL-2.0 Unicode-3.0 ZLIB openssl
	public-domain
"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror"

RDEPEND="
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-misc/xdg-utils
"

QA_PREBUILT="
	usr/bin/${MY_PN}
	usr/bin/${MY_PN}-desktop
"

src_install() {
	dobin usr/bin/${MY_PN} usr/bin/${MY_PN}-desktop

	local size
	for size in 32 128; do
		doicon -s ${size} usr/share/icons/hicolor/${size}x${size}/apps/${MY_PN}-desktop.png
	done
	doicon -s 256 usr/share/icons/hicolor/256x256@2/apps/${MY_PN}-desktop.png

	make_desktop_entry --eapi9 "${MY_PN}-desktop" -n "AntiGravity Switch" \
		-i "${MY_PN}-desktop" -c "Utility;" \
		-e "StartupWMClass=${MY_PN}-desktop" -e "Terminal=false"
}
