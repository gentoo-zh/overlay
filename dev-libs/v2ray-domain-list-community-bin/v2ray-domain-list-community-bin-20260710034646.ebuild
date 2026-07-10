# Copyright 2021-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Community managed domain list for V2Ray."
HOMEPAGE="https://github.com/v2fly/domain-list-community"
SRC_URI="https://github.com/v2fly/domain-list-community/releases/download/${PV}/dlc.dat.xz -> ${P}.dat.xz"

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~riscv ~x86"

RDEPEND="!dev-libs/v2ray-domain-list-community"

src_install() {
	insinto /usr/share/geosite/
	newins "${P}.dat" v2fly.dat
}
