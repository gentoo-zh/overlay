# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker systemd

DESCRIPTION="An advanced Web Panel • Built for SagerNet/Sing-Box"
HOMEPAGE="https://github.com/alireza0/s-ui"
SRC_URI="
	amd64? ( https://github.com/alireza0/s-ui/releases/download/v${PV}/s-ui-linux-amd64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://github.com/alireza0/s-ui/releases/download/v${PV}/s-ui-linux-arm64.tar.gz -> ${P}-arm64.tar.gz )
"
S="${WORKDIR}"
LICENSE="GPL-3"

SLOT="0"
KEYWORDS="~amd64"

RESTRICT="strip"

src_prepare() {
	sed -i 's|ExecStart=.*|ExecStart=/usr/bin/sui|' "${S}/s-ui/s-ui.service" || die
	sed -i 's|WorkingDirectory=.*|WorkingDirectory=/var/lib/s-ui|' "${S}/s-ui/s-ui.service" || die

	default
}

src_install() {
	dobin "${S}/s-ui/sui"
	systemd_dounit "${S}/s-ui/s-ui.service"
	keepdir /var/lib/s-ui
}
