# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

MY_PN="${PN%-bin}"
DESCRIPTION="Model and account manager with a local gateway for AI coding agents"
HOMEPAGE="https://github.com/yetone/magpie https://usemagpie.ai"
SRC_URI="
	amd64? ( https://github.com/yetone/magpie/releases/download/v${PV}/magpie-linux-amd64 -> ${P}-amd64 )
	arm64? ( https://github.com/yetone/magpie/releases/download/v${PV}/magpie-linux-arm64 -> ${P}-arm64 )
	https://raw.githubusercontent.com/yetone/magpie/v${PV}/build/icon/magpie.svg -> ${P}.svg
	https://raw.githubusercontent.com/yetone/magpie/v${PV}/LICENSE -> ${P}-LICENSE
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD BSD-2 MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="
	dev-libs/glib:2
	dev-libs/wayland
	dev-util/desktop-file-utils
	media-libs/fontconfig:1.0
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-misc/xdg-utils
"

QA_PREBUILT="usr/bin/${MY_PN}"

src_install() {
	newbin "${DISTDIR}/${P}-${ARCH}" "${MY_PN}"
	newicon -s scalable "${DISTDIR}/${P}.svg" "${MY_PN}.svg"
	make_desktop_entry --eapi9 "${MY_PN}" -a "%u" -n magpie -i "${MY_PN}" \
		-c "Development;Utility;" -e "MimeType=x-scheme-handler/magpie;" -e "Terminal=false"
	newdoc "${DISTDIR}/${P}-LICENSE" LICENSE
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "Disable upstream automatic updates with: magpie update auto off"
	elog "Use Portage to update magpie; do not use its built-in updater."
}
