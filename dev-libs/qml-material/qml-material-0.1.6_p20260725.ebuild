# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_PV="628f580b60f8e7195447ec9e27dae5cce5b0fcbc"

DESCRIPTION="A library of Qml implementing Google's Material Design"
HOMEPAGE="https://github.com/hypengw/QmlMaterial"
SRC_URI="
	https://github.com/hypengw/QmlMaterial/archive/${MY_PV}.tar.gz -> ${P}.tar.gz
	https://github.com/hypengw/QmlMaterial/raw/${MY_PV}/assets/MaterialSymbolsRounded.wght_400.opsz_24.fill_0.woff2
	https://github.com/hypengw/QmlMaterial/raw/${MY_PV}/assets/MaterialSymbolsRounded.wght_400.opsz_24.fill_1.woff2
"

S="${WORKDIR}/QmlMaterial-${MY_PV}"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	media-libs/freetype[brotli]
	dev-qt/qtbase:6[gui]
	dev-qt/qtdeclarative:6
	dev-qt/qtshadertools:6
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_unpack() {
	default
	cp -t "${S}/assets" \
		"${DISTDIR}/MaterialSymbolsRounded.wght_400.opsz_24.fill_0.woff2" \
		"${DISTDIR}/MaterialSymbolsRounded.wght_400.opsz_24.fill_1.woff2" || die
}
