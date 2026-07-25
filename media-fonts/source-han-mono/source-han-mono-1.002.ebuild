# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Adobe Source Han Mono: a Pan-CJK monospaced typeface"
HOMEPAGE="https://github.com/adobe-fonts/source-han-mono"
SRC_URI="https://github.com/adobe-fonts/${PN}/releases/download/${PV}/SourceHanMono.ttc -> ${P}.ttc"
S="${WORKDIR}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~loong ~riscv ~x86"

FONT_SUFFIX="ttc"

src_prepare() {
	default
	cp "${DISTDIR}"/${P}.ttc "${S}"/ || die
}
