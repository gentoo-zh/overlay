# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font unpacker

DESCRIPTION="遍黑体项目（Plangothic Project）"
HOMEPAGE="https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic_Project"
AUTHOR="Fitzgerald-Porthmouth-Koenigsegg"
REPO="Plangothic_Project"
SRC_URI="https://github.com/${AUTHOR}/${REPO}/archive/refs/tags/V${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${REPO}-${PV}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+otf static web"
REQUIRED_USE="|| ( otf static web )"

FONT_SUFFIX="otf"

src_unpack() {
	default

	# Flatten the font directory by copying all fonts file into ${S}
	find "${S}/fonts" \( -iname '*.otf' -o -iname '*.ttf' -o -iname '*.woff2' \) \
		 -exec cp "{}" "${S}/" \; || die
}

src_install() {
	use static && FONT_SUFFIX+=" ttf"
	use web && FONT_SUFFIX+=" woff2"

	font_src_install
}
