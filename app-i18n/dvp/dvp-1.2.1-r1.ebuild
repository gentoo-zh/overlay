# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PV=${PV//./_}
MY_P="${PN}-${MY_PV}"

DESCRIPTION="The kbd keymap for Programmer Dvorak"
HOMEPAGE="https://www.kaufmann.no/roland/dvorak/index.html"
SRC_URI="https://www.kaufmann.no/downloads/linux/${MY_P}.map.gz"

S="${WORKDIR}"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~mips ~x86"

DEPEND="app-arch/gzip"
RDEPEND="sys-apps/kbd"

src_prepare() {
	eapply_user
	mv ${MY_P}.map dvp.map
	gzip -9 dvp.map
}

src_install() {
	insinto /usr/share/keymaps/i386/dvorak
	doins dvp.map.gz
}
