# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DBIP_V="${PV:0:4}-${PV:4:2}"

DESCRIPTION="GeoIP for V2Ray"
HOMEPAGE="https://github.com/v2fly/geoip"
SRC_URI="
	https://github.com/v2fly/geoip/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/geoip/releases/download/${PV}/geoip-${PV}-vendor.tar.xz
	https://download.db-ip.com/free/dbip-country-lite-${DBIP_V}.mmdb.gz
"

S="${WORKDIR}/geoip-${PV}"

LICENSE="CC-BY-SA-4.0 CC-BY-4.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="!dev-libs/v2ray-geoip-bin"
BDEPEND=">=dev-lang/go-1.26"

src_unpack() {
	go-module_src_unpack

	cd "${S}" || die
	mkdir db-ip || die
	cp "${WORKDIR}/dbip-country-lite-${DBIP_V}.mmdb" db-ip/dbip-country-lite.mmdb || die
}

src_compile() {
	ego run ./
}

src_install() {
	insinto /usr/share/geoip/
	newins output/geoip.dat v2fly.dat
}
