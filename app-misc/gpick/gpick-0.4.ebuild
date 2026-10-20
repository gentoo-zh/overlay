# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

DESCRIPTION="Advanced color picker written in C++ using GTK+ toolkit"
HOMEPAGE="https://github.com/thezbyg/gpick"
SRC_URI="https://github.com/thezbyg/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="+gtk3 nls"

RDEPEND="
	>=dev-lang/lua-5.2:=
	dev-libs/boost:=
	dev-libs/expat
	dev-util/ragel
	nls? ( sys-devel/gettext )
	gtk3? ( x11-libs/gtk+:3 )
	!gtk3? ( x11-libs/gtk+:2 )
"

DEPEND="${RDEPEND}"

PATCHES=( "${FILESDIR}/${P}-fix-segfault-on-start.patch" )

src_prepare() {
	cp "${FILESDIR}/.version" . || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DUSE_GTK3=$(usex gtk3 ON OFF)
		-DENABLE_NLS=$(usex nls ON OFF)
		-DLUA_TYPE=C
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	mv "${D}/usr/share/doc/${PN}" "${D}/usr/share/doc/${PF}" || die
}
