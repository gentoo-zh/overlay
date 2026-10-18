# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

MY_P="${PN}-v${PV}"

DESCRIPTION="Traditional Chinese variant of LXGW WenKai"
HOMEPAGE="https://github.com/lxgw/LxgwWenkaiTC"
SRC_URI="https://github.com/lxgw/LxgwWenkaiTC/releases/download/v${PV}/${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong ~riscv ~x86"

FONT_SUFFIX="ttf"
