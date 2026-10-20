# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

COMMIT="da53f36e4d09712999369a0f62c698958e5f513c"

DESCRIPTION="Traditional Chinese font based on Source Han Sans with classical glyphs"
HOMEPAGE="https://github.com/MoonlitOwen/ChocolateSans"
SRC_URI="https://github.com/MoonlitOwen/ChocolateSans/raw/${COMMIT}/fonts/ttf/ChocolateClassicalSans-Regular.ttf -> ${P}.ttf"
S="${WORKDIR}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

FONT_SUFFIX="ttf"

src_unpack() {
	cp "${DISTDIR}/${P}.ttf" "${S}/ChocolateClassicalSans-Regular.ttf" || die
}
