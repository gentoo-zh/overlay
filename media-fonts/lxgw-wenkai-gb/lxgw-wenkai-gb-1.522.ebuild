# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

MY_P="${PN}-v${PV}"

DESCRIPTION="LXGW WenKai following the GB 18030 (national standard) glyph forms"
HOMEPAGE="https://github.com/lxgw/LxgwWenkaiGB"
SRC_URI="https://github.com/lxgw/LxgwWenkaiGB/releases/download/v${PV}/${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong ~riscv ~x86"

FONT_SUFFIX="ttf"
