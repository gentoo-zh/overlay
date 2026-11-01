# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support"
HOMEPAGE="https://xtls.github.io/ https://github.com/XTLS/Xray-core"
SRC_URI="https://github.com/XTLS/Xray-core/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/Xray-core/releases/download/v${PV}/Xray-core-${PV}-vendor.tar.xz"

S="${WORKDIR}/${PN}-core-${PV}"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~riscv ~x86"

DEPEND="app-alternatives/v2ray-geoip
	app-alternatives/v2ray-geosite"
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.27.0"

src_compile() {
	ego build -o xray -gcflags="all=-l=4" -ldflags "-X github.com/xtls/xray-core/core.build=${PV}" ./main
}

src_install() {
	dobin xray
	newinitd "${FILESDIR}/xray.initd" xray
	systemd_dounit "${FILESDIR}/xray.service"
	systemd_newunit "${FILESDIR}/xray_at.service" xray@.service
	dosym -r /usr/share/v2ray/geosite.dat /usr/share/xray/geosite.dat
	dosym -r /usr/share/v2ray/geoip.dat /usr/share/xray/geoip.dat
	keepdir /etc/xray
}
