# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd go-module

DESCRIPTION="A fork of trojan-go"
HOMEPAGE="https://github.com/Potterli20/trojan-go-fork"
SRC_URI="
	https://github.com/Potterli20/trojan-go-fork/archive/refs/tags/V${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/blackteahamburger/gentoo-deps/releases/download/${P}/${P}-vendor.tar.xz
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="
	app-alternatives/v2ray-geoip
	app-alternatives/v2ray-geosite
"
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.25.7"

src_compile() {
	ego build -tags "full"
}

src_install() {
	dobin trojan-go-fork
	dosym -r /usr/bin/trojan-go-fork /usr/bin/trojan-go

	insinto /etc/trojan-go
	doins example/*.json

	systemd_dounit example/*.service

	dosym -r /usr/share/v2ray/geosite.dat /usr/share/trojan-go/geosite.dat
	dosym -r /usr/share/v2ray/geoip.dat /usr/share/trojan-go/geoip.dat
}
