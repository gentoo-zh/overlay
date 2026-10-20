# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font

MY_PN="Zhudou-Sans"

DESCRIPTION="A font family for CJK symbols and punctuation, derived from Noto Sans"
HOMEPAGE="https://github.com/Buernia/Zhudou-Sans"
SRC_URI="https://github.com/Buernia/Zhudou-Sans/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${MY_PN}-${PV}"
LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

FONT_SUFFIX="ttf"

src_unpack() {
	default

	# remove README.md to prevent it from being installed as doc
	rm "${S}/README.md" || die

	# mv font files from sub-dirs to ${S}
	mv "${S}"/fonts/ttf/*.ttf "${S}"/ || die
	mv "${S}"/fonts/variable/*.ttf "${S}"/ || die
}
