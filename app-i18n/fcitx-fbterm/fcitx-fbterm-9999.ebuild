# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 xdg

MY_PN="fcitx5-fbterm"
DESCRIPTION="Fcitx5 input method frontend for fbterm"
HOMEPAGE="https://github.com/fcitx/fcitx5-fbterm"
EGIT_REPO_URI="https://github.com/fcitx/${MY_PN}.git"

LICENSE="GPL-3+"
SLOT="5"
KEYWORDS=""

DEPEND="
	>=app-i18n/fcitx-5.1.0:5
	app-i18n/fcitx-gtk:5
	dev-libs/glib:2
"
RDEPEND="
	${DEPEND}
	app-i18n/fbterm
"
BDEPEND="
	kde-frameworks/extra-cmake-modules:0
	virtual/pkgconfig
"

src_prepare() {
	# Live upstream still declares cmake_minimum_required 3.6; raise it past
	# ECM's compatibility threshold so it stops warning.
	sed -i -e '/cmake_minimum_required/s/VERSION 3\.6/VERSION 3.16/' CMakeLists.txt || die
	cmake_src_prepare
}
