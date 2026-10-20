# Copyright 2021-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit font

MY_PN="open-huninn-font"
DESCRIPTION="An opensource Chinese font by justfont, based on Kosugi Maru and Varela Round"
HOMEPAGE="https://justfont.com/huninn/"
SRC_URI="https://github.com/justfont/open-huninn-font/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"
LICENSE="OFL-1.1"
SLOT="0"

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ppc ~ppc64 ~s390 ~sparc ~x86"

FONT_SUFFIX="ttf"
FONT_S="${S}/font"

src_unpack() {
	default

	# Strip suffix of 1.1 vertion to ignore it
	mv "${S}/font/${PN}-1.1.ttf" "${S}/font/${PN}-1.1" || die
}
