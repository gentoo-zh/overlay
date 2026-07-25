# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="fcitx5-libthai"
inherit cmake unpacker xdg

DESCRIPTION="Thai input method for Fcitx5 based on libthai"
HOMEPAGE="https://github.com/fcitx/fcitx5-libthai"
SRC_URI="https://download.fcitx-im.org/fcitx5/${MY_PN}/${MY_PN}-${PV}.tar.zst"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="GPL-2+"
SLOT="5"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="
	>=app-i18n/fcitx-5.1.12:5
	dev-libs/libthai
	virtual/libiconv
"
RDEPEND="${DEPEND}"
BDEPEND="
	kde-frameworks/extra-cmake-modules:0
	sys-devel/gettext
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${P}-cmake_316.patch
)

src_configure() {
	local mycmakeargs=(
		-DENABLE_TEST=$(usex test)
	)
	cmake_src_configure
}
