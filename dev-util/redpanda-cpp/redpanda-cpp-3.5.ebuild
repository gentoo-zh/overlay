# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake xdg
DESCRIPTION="A lightweight yet powerful C/C++/GNU Assembly IDE"
HOMEPAGE="http://royqh.net/redpandacpp/"
SRC_URI="https://github.com/royqh1979/RedPanda-CPP/archive/refs/tags/v${PV}.tar.gz -> redpanda-cpp-${PV}.tar.gz"
S="${WORKDIR}/RedPanda-CPP-${PV}"
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="
	dev-qt/qtbase:6[gui,network,widgets,xml]
	dev-qt/qtsvg:6
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-qt/qttools:6[linguist]
	dev-vcs/git
"

src_configure(){
	local mycmakeargs=( -DBUILD_TESTING=OFF )
	cmake_src_configure
}

src_install(){
	cmake_src_install
	rm -r "${ED}/usr/share/doc/RedPandaCPP" || die
}
