# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

DESCRIPTION="The Mint-Y icon theme, based on Paper and Moka"
HOMEPAGE="https://github.com/linuxmint/mint-y-icons/"
SRC_URI="https://github.com/linuxmint/mint-y-icons/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CC-BY-4.0 GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

src_install() {
	insinto /usr/share/icons
	doins -r usr/share/icons/.
}
