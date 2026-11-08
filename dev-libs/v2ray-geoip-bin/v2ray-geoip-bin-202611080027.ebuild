# Copyright 2021-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="GeoIP for V2Ray"
HOMEPAGE="https://github.com/v2fly/geoip"
SRC_URI="https://github.com/v2fly/geoip/releases/download/${PV}/geoip.dat -> ${P}.dat"

S="${WORKDIR}"

LICENSE="CC-BY-SA-4.0 CC-BY-4.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~riscv ~x86"

src_install() {
	insinto /usr/share/geoip/
	newins "${DISTDIR}/${P}.dat" v2fly.dat
}
