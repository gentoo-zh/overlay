# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Plays & manages your music library"
HOMEPAGE="https://harmonoid.com/
	https://github.com/harmonoid/harmonoid
"
MY_PV="${PV/_p/-hotfix}"
BASE_URI="
https://github.com/alexmercerind2/harmonoid-releases/releases/download/v${MY_PV}"
SRC_URI="
	amd64? ( ${BASE_URI}/${PN}-linux-x86_64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( ${BASE_URI}/${PN}-linux-aarch64.tar.gz -> ${P}-arm64.tar.gz )
"
S="${WORKDIR}"
LICENSE="PolyForm-Strict-1.0.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist mirror"

QA_PREBUILT="usr/share/harmonoid/*"

DEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/glib:2
	amd64? (
		media-libs/alsa-lib
		media-libs/fontconfig
		media-libs/libpulse
		x11-libs/libX11
	)
	media-libs/harfbuzz
	media-libs/libepoxy
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/pango
"
RDEPEND="${DEPEND}"

src_install() {
	# The aarch64 tarball ships the x86-64 build of this library, and no
	# aarch64 object links it.
	if use arm64; then
		rm usr/share/harmonoid/lib/libdiscord_partner_sdk.so || die
	fi

	insinto /usr
	doins -r usr/*

	fperms +x "/usr/share/harmonoid/harmonoid"

	for size in 128 256; do
		doicon -s $size \
			usr/share/icons/hicolor/"$size"x"$size"/apps/harmonoid.png
	done
}

pkg_postinst() {
	xdg_pkg_postinst

	if [ "$(uname -m)" = "aarch64" ]; then
		elog "libflutter_linux_gtk.so from the official arm64 flutter engine"
		elog "is not linked against fontconfig, which prevents flutter from"
		elog "finding system CJK fonts, rendering those characters tofu box."
		elog " "
		elog "The flutter officials have noticed this and are in progress."
		elog "( https://github.com/flutter/flutter/pull/180235 )"
		elog "Rebuilding flutter engine with fontconfig enabled might"
		elog "tackle the issue temporarily."
	fi
}
