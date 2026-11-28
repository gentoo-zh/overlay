# Copyright 2021-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 xdg

DESCRIPTION="Japanese SKK input engine for Fcitx5"
HOMEPAGE="https://fcitx-im.org/ https://github.com/fcitx/fcitx5-skk"
EGIT_REPO_URI="https://github.com/fcitx/fcitx5-skk"

LICENSE="GPL-3+"
SLOT="5"
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
