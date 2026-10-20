# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font

DESCRIPTION="An open-source Chinese font derived from Klee One (Fontworks)"
HOMEPAGE="https://github.com/ButTaiwan/iansui"
SRC_URI="https://github.com/ButTaiwan/iansui/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

FONT_SUFFIX="ttf"
FONT_S="${WORKDIR}/${P}/fonts/ttf"
