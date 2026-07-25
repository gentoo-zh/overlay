# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="fcitx5-kkc"

inherit cmake unpacker xdg

DESCRIPTION="Japanese Kana Kanji conversion (libkkc) input method for Fcitx5"
HOMEPAGE="https://github.com/fcitx/fcitx5-kkc"
SRC_URI="https://download.fcitx-im.org/fcitx5/${MY_PN}/${MY_PN}-${PV}.tar.zst"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="GPL-3+"
SLOT="5"
KEYWORDS="~amd64"
IUSE="+qt6"

RDEPEND="
	>=app-i18n/fcitx-5.1.13:5
	app-i18n/libkkc
	qt6? ( app-i18n/fcitx-qt:5[qt6] )
"
DEPEND="${RDEPEND}"
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
		-DENABLE_QT=$(usex qt6)
	)
	cmake_src_configure
}
