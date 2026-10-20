# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit xdg qmake-utils
DESCRIPTION="A lightweight yet powerful C/C++/GNU Assembly IDE"
HOMEPAGE="http://royqh.net/redpandacpp/"
SRC_URI="https://github.com/royqh1979/RedPanda-CPP/archive/refs/tags/v${PV}.tar.gz -> redpanda-cpp-${PV}.tar.gz"
S="${WORKDIR}/RedPanda-CPP-${PV}"
LICENSE="GPL-3"
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

PATCHES=( "${FILESDIR}/${P}-fix-linux-utf8.patch" )

src_configure(){
	OPTIONS="PREFIX=/usr LIBEXECDIR=libexec XDG_ADAPTIVE_ICON=ON"
	eqmake6 ${OPTIONS} Red_Panda_CPP.pro
}

src_install(){
	emake INSTALL_ROOT="${ED}" install
	rm -r "${ED}/usr/share/doc/RedPandaCPP" || die
	dodoc README.md NEWS.md
}
