# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Open source, compact, and material designed cursor set"
HOMEPAGE="https://www.bibata.live"
RELEASE_URI="https://github.com/ful1e5/Bibata_Cursor/releases/download/v${PV}/Bibata-"
SRC_URI="
	modern-style? ( color-amber? ( lefthanded? ( ${RELEASE_URI}Modern-Amber-Right.tar.xz ) ) )
	modern-style? ( color-amber? ( righthanded? ( ${RELEASE_URI}Modern-Amber.tar.xz ) ) )
	modern-style? ( color-black? ( lefthanded? ( ${RELEASE_URI}Modern-Classic-Right.tar.xz ) ) )
	modern-style? ( color-black? ( righthanded? ( ${RELEASE_URI}Modern-Classic.tar.xz ) ) )
	modern-style? ( color-white? ( lefthanded? ( ${RELEASE_URI}Modern-Ice-Right.tar.xz ) ) )
	modern-style? ( color-white? ( righthanded? ( ${RELEASE_URI}Modern-Ice.tar.xz ) ) )
	original-style? ( color-amber? ( lefthanded? ( ${RELEASE_URI}Original-Amber-Right.tar.xz ) ) )
	original-style? ( color-amber? ( righthanded? ( ${RELEASE_URI}Original-Amber.tar.xz ) ) )
	original-style? ( color-black? ( lefthanded? ( ${RELEASE_URI}Original-Classic-Right.tar.xz ) ) )
	original-style? ( color-black? ( righthanded? ( ${RELEASE_URI}Original-Classic.tar.xz ) ) )
	original-style? ( color-white? ( lefthanded? ( ${RELEASE_URI}Original-Ice-Right.tar.xz ) ) )
	original-style? ( color-white? ( righthanded? ( ${RELEASE_URI}Original-Ice.tar.xz ) ) )
"

S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

IUSE="+righthanded lefthanded +modern-style original-style color-amber +color-black color-white"
REQUIRED_USE="
	|| ( righthanded lefthanded )
	|| ( modern-style original-style )
	|| ( color-amber color-black color-white )

"

src_install() {
	insinto /usr/share/icons
	doins -r .
}
