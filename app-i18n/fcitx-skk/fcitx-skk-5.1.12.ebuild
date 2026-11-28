# Copyright 2021-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="fcitx5-skk"

inherit cmake unpacker xdg

DESCRIPTION="Japanese SKK input engine for Fcitx5"
HOMEPAGE="https://fcitx-im.org/ https://github.com/fcitx/fcitx5-skk"
SRC_URI="https://download.fcitx-im.org/fcitx5/${MY_PN}/${MY_PN}-${PV}.tar.zst"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="GPL-3+"
SLOT="5"
KEYWORDS="~amd64 ~x86"
IUSE="qt6 test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=app-i18n/fcitx-5.1.22:5
	>=app-i18n/libskk-1.1.0
	dev-libs/glib:2
	app-i18n/skk-jisyo
	qt6? (
		>=app-i18n/fcitx-qt-5.1.4:5[qt6(+),-onlyplugin]
		dev-qt/qtbase:6[dbus,gui,widgets]
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	kde-frameworks/extra-cmake-modules:0
	virtual/pkgconfig
"

# cmake_minimum_required is 3.6.0
CMAKE_QA_COMPAT_SKIP=1

src_configure() {
	local mycmakeargs=(
		-DENABLE_QT=$(usex qt6)
		-DENABLE_TEST=$(usex test)
	)
	cmake_src_configure
}
