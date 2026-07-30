# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Plays & manages your music library"
HOMEPAGE="https://harmonoid.com/
	https://github.com/harmonoid/harmonoid
"
BASE_URI="
https://github.com/alexmercerind2/harmonoid-releases/releases/download/v${PV}"
SRC_URI="
	amd64? ( ${BASE_URI}/${PN}-linux-x86_64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( ${BASE_URI}/${PN}-linux-aarch64.tar.gz -> ${P}-arm64.tar.gz )
"
S="${WORKDIR}"
LICENSE="harmonoid-EULA"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

QA_PRESTRIPPED="usr/share/harmonoid/lib/libapp.so"

DEPEND="
	app-accessibility/at-spi2-core
	x11-libs/gtk+:3
"
RDEPEND="${DEPEND}"

src_install() {
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
		ewarn "libflutter_linux_gtk.so from the official arm64 flutter engine"
		ewarn "is not linked against fontconfig, which prevents flutter from"
		ewarn "finding system CJK fonts, rendering those characters tofu box."
		ewarn " "
		ewarn "The flutter officials have noticed this and are in progress."
		ewarn "( https://github.com/flutter/flutter/pull/180235 )"
		ewarn "Rebuilding flutter engine with fontconfig enabled might"
		ewarn "tackle the issue temporarily."
	fi
}
