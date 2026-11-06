# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="LXGW Marker Gothic: a handwritten marker-style Chinese font"
HOMEPAGE="https://github.com/lxgw/LxgwMarkerGothic"
SRC_URI="https://github.com/lxgw/LxgwMarkerGothic/releases/download/v${PV}/LxgwMarkerGothic-v${PV}.zip"
S="${WORKDIR}/LxgwMarkerGothic-v${PV}/fonts/ttf"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong ~riscv ~x86"

FONT_SUFFIX="ttf"

BDEPEND="app-arch/unzip"
