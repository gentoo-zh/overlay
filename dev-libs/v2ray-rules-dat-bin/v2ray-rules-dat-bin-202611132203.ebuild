# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Enhanced edition of V2Ray rules dat files"
HOMEPAGE="https://github.com/Loyalsoldier/v2ray-rules-dat"
SRC_URI="
	geosite? ( https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${PV}/geosite.dat -> ${P}-geosite.dat )
	geoip? ( https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${PV}/geoip.dat -> ${P}-geoip.dat )
"

S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~riscv ~x86"

IUSE="+geosite +geoip"
REQUIRED_USE="|| ( geosite geoip )"

src_install() {
	if use geosite; then
		insinto /usr/share/geosite/
		newins "${DISTDIR}/${P}-geosite.dat" loyalsoldier.dat
	fi
	if use geosite; then
		insinto /usr/share/geoip/
		newins "${DISTDIR}/${P}-geoip.dat" loyalsoldier.dat
	fi
}
