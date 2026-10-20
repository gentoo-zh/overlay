# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font

MY_PN="Tiejili"
DESCRIPTION="An open-source font that extends  Reggae One to Chinese"
HOMEPAGE="https://github.com/Buernia/Tiejili"
SRC_URI="https://github.com/Buernia/Tiejili/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

FONT_SUFFIX="ttf otf"

src_unpack() {
	default

	# remove README to prevent it from being installed as doc
	rm "${S}/README.md" || die

	# mv font files from sub-dir to ${S}
	mv "${S}"/fonts/ttf/*.ttf "${S}"/ || die
	mv "${S}"/fonts/otf/*.otf "${S}"/ || die
}
