# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature unpacker xdg

DESCRIPTION="Reasonix desktop client"
HOMEPAGE="https://reasonix.io https://github.com/esengine/DeepSeek-Reasonix"
SRC_URI="
	https://dl.reasonix.io/desktop-v${PV}/Reasonix-linux-amd64.deb
		-> ${P}-amd64.deb
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

RDEPEND="
	dev-libs/glib
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:3
"

QA_PREBUILT="
	usr/bin/reasonix-desktop
	usr/bin/reasonix-launcher
"

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	# Deb also ships /usr/bin/reasonix; leave that path to reasonix-bin.
	dobin usr/bin/reasonix-desktop
	dobin usr/bin/reasonix-launcher

	# Skip update-helper and polkit: they implement .deb self-update.
	domenu usr/share/applications/reasonix.desktop

	local size
	for size in 16 24 32 48 64 128 256 512; do
		doicon -s ${size} usr/share/icons/hicolor/${size}x${size}/apps/reasonix-desktop.png
	done
	doicon -s scalable usr/share/icons/hicolor/scalable/apps/reasonix-desktop.svg
	doicon usr/share/pixmaps/reasonix-desktop.png
}

pkg_postinst() {
	xdg_pkg_postinst
	optfeature "terminal agent CLI" dev-util/reasonix-bin
}
