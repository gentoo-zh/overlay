# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop pax-utils unpacker xdg

DESCRIPTION="Privacy-first, self-hosted personal knowledge management system"
HOMEPAGE="https://b3log.org/siyuan/ https://github.com/siyuan-note/siyuan"
SRC_URI="
	amd64? (
		https://github.com/siyuan-note/siyuan/releases/download/v${PV}/siyuan-${PV}-linux.deb
			-> ${P}-amd64.deb
	)
	arm64? (
		https://github.com/siyuan-note/siyuan/releases/download/v${PV}/siyuan-${PV}-linux-arm64.deb
			-> ${P}-arm64.deb
	)
"
S="${WORKDIR}"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="suid"
RESTRICT="strip"

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
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="*"

src_install() {
	dodir /opt
	mv opt/SiYuan "${ED}/opt/siyuan" || die

	# The setuid sandbox is legacy; default to the user-namespace sandbox
	# and only mark chrome-sandbox setuid when the user opts in.
	use suid && fperms 4755 /opt/siyuan/chrome-sandbox
	pax-mark m "${ED}"/opt/siyuan/siyuan
	dosym -r /opt/siyuan/siyuan /usr/bin/siyuan

	# Launch through PATH so the entry does not encode the /opt layout.
	sed -i 's|^Exec=.*|Exec=siyuan %U|' usr/share/applications/*.desktop || die
	# Upstream names the entry per arch (siyuan.desktop on arm64), so install it
	# under the app-id the window reports, letting desktop environments match
	# the running window to this entry.
	newmenu usr/share/applications/*.desktop org.b3log.siyuan.desktop

	insinto /usr/share/icons
	doins -r usr/share/icons/hicolor
}
