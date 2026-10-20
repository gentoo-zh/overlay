# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="Nordzy-cursors"
DESCRIPTION="Cursor theme using the Nord color palette and based on Vimix and cz-Viator"
HOMEPAGE="https://github.com/guillaumeboehm/Nordzy-cursors"
SRC_URI="
	https://github.com/guillaumeboehm/${MY_PN}/releases/download/v${PV}/${MY_PN}.tar.gz -> ${P}.tar.gz
	nord-white? \
	( https://github.com/guillaumeboehm/${MY_PN}/releases/download/v${PV}/${MY_PN}-white.tar.gz -> ${P}-white.tar.gz )
"

S="${WORKDIR}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="nord-white"

src_install() {
	insinto /usr/share/icons/
	doins -r ./Nordzy-cursors
	use nord-white && doins -r ./Nordzy-cursors-white
}
