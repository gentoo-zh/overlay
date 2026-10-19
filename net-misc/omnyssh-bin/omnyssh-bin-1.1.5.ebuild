# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="SSH dashboard, terminal, and SFTP file manager"
HOMEPAGE="https://github.com/timhartmann7/omnyssh"
SRC_URI="
	amd64? (
		https://github.com/timhartmann7/omnyssh/releases/download/v${PV}/OmnySSH-x86_64.deb
			-> ${P}-amd64.deb
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0 MIT"
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
	x11-misc/xdg-utils
"

QA_PREBUILT="usr/bin/OmnySSH"

src_install() {
	dobin usr/bin/OmnySSH
	domenu usr/share/applications/OmnySSH.desktop

	local size
	for size in 32 128; do
		doicon -s ${size} usr/share/icons/hicolor/${size}x${size}/apps/OmnySSH.png
	done
	doicon -s 256 usr/share/icons/hicolor/256x256@2/apps/OmnySSH.png
}
